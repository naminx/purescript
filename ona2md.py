#!/usr/bin/env python3
import sys
import re
from bs4 import BeautifulSoup


def clean_text(text):
    """
    Cleans up text by replacing newlines with spaces and collapsing multiple spaces.
    Used for conversational text, NOT for code.
    """
    if not text:
        return ""
    text = text.replace("\n", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def get_diff_content(diff_container):
    """
    Extracts diff content from the raw HTML structure,
    preserving exact indentation found in the font-mono spans.
    """
    scrollable = diff_container.find(id="scrollable")
    if not scrollable:
        return ""

    # In the raw file, code lines are consistently styled with 'font-mono'.
    lines = scrollable.find_all("div", class_=lambda c: c and "font-mono" in c)

    diff_lines = []
    for line in lines:
        spans = line.find_all("span")
        if len(spans) >= 2:
            # Span 0: The marker (+, -, or space)
            marker = spans[0].get_text(strip=True)
            if not marker:
                marker = " "

            # Span 1: The Code Content
            # CRITICAL: strip=False preserves the leading spaces (indentation)
            content = spans[1].get_text(strip=False)

            diff_lines.append(f"{marker} {content}")

    return "\n".join(diff_lines)


def parse_html_to_markdown(input_file):
    try:
        with open(input_file, "r", encoding="utf-8") as f:
            html_content = f.read()

        soup = BeautifulSoup(html_content, "html.parser")
        md_lines = []

        container = soup.find(id="conversation-content")
        if not container:
            print("Error: Could not find #conversation-content", file=sys.stderr)
            sys.exit(1)

        conversation_wrapper = container.find(
            "div", class_="mx-auto"
        ) or container.find("div")

        for node in conversation_wrapper.find_all(recursive=False):
            classes = node.get("class", [])

            # --- 1. User Messages ---
            if "user-message" in classes:
                markdown_div = node.find("div", class_="markdown-container")
                if markdown_div:
                    text_parts = []
                    for child in markdown_div.children:
                        if child.name:
                            cleaned = clean_text(child.get_text(strip=True))
                            if cleaned:
                                text_parts.append(cleaned)

                    full_text = "\n".join(f"> {line}" for line in text_parts)
                    md_lines.append(f"\n{full_text}\n")

            # --- 2. Model/System Outputs ---
            elif "flex" in classes and "w-full" in classes:
                group = node.find("div", class_="group")
                if group:
                    items_wrapper = group.find("div", class_="flex flex-col gap-4")
                    if items_wrapper:
                        process_group_items(items_wrapper, md_lines)

        # Write to stdout
        print("\n".join(md_lines))

    except FileNotFoundError:
        print(f"Error: File {input_file} not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def process_group_items(wrapper, md_lines):
    for item in wrapper.children:
        if item.name != "div":
            continue

        # --- PRIORITY CHECK: Collapsible / Diffs ---
        # We must check this BEFORE checking for generic buttons,
        # because these containers INCLUDE a button (the header).
        if item.has_attr("data-state"):
            # 1. Extract Title/Filename (always)
            # Look for the trigger button inside
            trigger_button = item.find("button")
            file_path = None

            if trigger_button:
                # Usually in a p.truncate inside the button
                p_trunc = trigger_button.find("p", class_="truncate")
                if p_trunc:
                    file_path = clean_text(p_trunc.get_text(strip=True))

            # Fallback: sometimes the p is just inside the item header
            if not file_path:
                header_p = item.find(
                    "p", class_=lambda c: c and "truncate" in c and "font-bold" in c
                )
                if header_p:
                    file_path = clean_text(header_p.get_text(strip=True))

            if file_path:
                md_lines.append(f"\n_{file_path}_\n")

            # 2. Extract Diff Content (only if open)
            if item.get("data-state") == "open":
                diff_content = get_diff_content(item)
                if diff_content:
                    md_lines.append("```diff")
                    md_lines.append(diff_content)
                    md_lines.append("```\n")

            # Stop processing this item (don't treat it as a generic button)
            continue

        # --- A. Standard Text ---
        markdown_div = item.find("div", class_="markdown-container")
        if markdown_div:
            text_blocks = []
            for child in markdown_div.children:
                if child.name in ["p", "li", "h1", "h2", "h3", "h4"]:
                    cleaned = clean_text(child.get_text(strip=True))
                    if not cleaned:
                        continue
                    if "mb-4" in child.get("class", []) and child.name == "p":
                        text_blocks.append(f"**{cleaned}**")
                    else:
                        text_blocks.append(cleaned)
                elif child.name in ["ul", "ol"]:
                    for i, li in enumerate(child.find_all("li")):
                        prefix = f"{i+1}." if child.name == "ol" else "-"
                        li_text = clean_text(li.get_text(strip=True))
                        text_blocks.append(f"{prefix} {li_text}")
                elif child.name == "table":
                    text_blocks.append(process_table(child))
                elif child.name == "pre":
                    code = child.get_text(strip=False)
                    text_blocks.append(f"```\n{code}\n```")

            if text_blocks:
                md_lines.append("\n" + "\n\n".join(text_blocks) + "\n")
            continue

        # --- B. Headers (TODOs) ---
        header = item.find("h2", class_="text-xl")
        if header:
            text = clean_text(header.get_text())
            badge = item.find("div", string="TODO")
            suffix = " [TODO]" if badge else ""
            md_lines.append(f"\n## {text}{suffix}\n")
            continue

        # --- C. Generic Buttons (Tools) ---
        # Only check this if it wasn't a collapsible (handled above)
        button = item.find("button")
        if button:
            span_trunc = button.find("span", class_="truncate")
            if span_trunc:
                text = clean_text(span_trunc.get_text())
                md_lines.append(f"- {text}")
                continue

            p_trunc = button.find("p", class_="truncate")
            if p_trunc:
                text = clean_text(p_trunc.get_text())
                md_lines.append(f"\n_{text}_\n")
                continue

        # --- D. Loose Tables ---
        if item.find("table"):
            md_lines.append(process_table(item.find("table")))


def process_table(table_node):
    lines = []
    headers = [clean_text(th.get_text()) for th in table_node.find_all("th")]
    if not headers:
        first_row = table_node.find("tr")
        if first_row:
            headers = [clean_text(td.get_text()) for td in first_row.find_all("td")]

    if headers:
        lines.append("| " + " | ".join(headers) + " |")
        lines.append("| " + " | ".join(["---"] * len(headers)) + " |")

    tbody = table_node.find("tbody") or table_node
    start_idx = 1 if (not table_node.find("thead") and headers) else 0

    rows = tbody.find_all("tr")[start_idx:]
    for tr in rows:
        cols = [clean_text(td.get_text()) for td in tr.find_all("td")]
        if cols:
            lines.append("| " + " | ".join(cols) + " |")

    return "\n" + "\n".join(lines) + "\n"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ona2md.py <input_file.html>", file=sys.stderr)
        print("Converts HTML conversation to Markdown and writes to stdout", file=sys.stderr)
        sys.exit(1)

    input_filename = sys.argv[1]
    parse_html_to_markdown(input_filename)
