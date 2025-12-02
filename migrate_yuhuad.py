#!/usr/bin/env python3
"""
MySQL to PostgreSQL Customer Data Migration Script

Converts yuhuad2.sql (MySQL dump) to PostgreSQL-compatible format.
Groups customer records by base_id and consolidates goldtype rows.

Usage:
    python migrate_yuhuad.py yuhuad2.sql [--output output.sql] [--direct]
    
Options:
    --output FILE    Write SQL to file (default: stdout)
    --direct         Connect directly to PostgreSQL and insert data
    --db-host HOST   PostgreSQL socket directory (default: .pgdata)
    --db-port PORT   PostgreSQL port (only for TCP, omit for Unix socket)
    --db-name NAME   Database name (default: huatkimhang)
    --db-user USER   Database user (default: postgres)
    --db-pass PASS   Database password (default: postgres)
    --validate-only  Only validate data, don't generate output
"""

import re
import sys
import argparse
from datetime import datetime
from decimal import Decimal
from collections import defaultdict
from typing import Dict, List, Tuple, Optional

class CustomerRecord:
    """Represents a consolidated customer record"""
    def __init__(self, base_id: int, base_name: str):
        self.base_id = base_id
        self.base_name = base_name
        self.money = Decimal('0.00')
        self.gram_jewelry = Decimal('0.000')
        self.gram_bar96 = Decimal('0.000')
        self.gram_bar99 = Decimal('0.000')
        self.latest_date = None
        self.row_count = 0
        
    def add_row(self, goldtype: int, gold: Decimal, money: Decimal, date_str: str):
        """Add data from a MySQL row"""
        self.row_count += 1
        self.money += money
        
        if goldtype == 1:
            self.gram_jewelry = gold
        elif goldtype == 2:
            self.gram_bar96 = gold
        elif goldtype == 3:
            self.gram_bar99 = gold
            
        # Track latest date
        if date_str and date_str != 'NULL':
            try:
                row_date = datetime.strptime(date_str, '%Y-%m-%d %H:%M:%S')
                if self.latest_date is None or row_date > self.latest_date:
                    self.latest_date = row_date
            except ValueError:
                pass
    
    def to_sql_values(self) -> str:
        """Generate SQL VALUES clause"""
        updated_at = self.latest_date.strftime('%Y-%m-%d %H:%M:%S') if self.latest_date else 'NOW()'
        
        return (
            f"('{self.escape_sql(self.base_name)}', "
            f"{self.money}, "
            f"{self.gram_jewelry}, 0.000, "
            f"{self.gram_bar96}, 0.000, "
            f"{self.gram_bar99}, 0.000, "
            f"NOW(), '{updated_at}')"
        )
    
    @staticmethod
    def escape_sql(s: str) -> str:
        """Escape single quotes for SQL"""
        return s.replace("'", "''")
    
    def __repr__(self):
        return f"Customer({self.base_name}, jewelry={self.gram_jewelry}g, bar96={self.gram_bar96}g, bar99={self.gram_bar99}g, money={self.money})"


def parse_mysql_dump(filepath: str) -> Dict[int, CustomerRecord]:
    """
    Parse MySQL dump file and extract customer records grouped by base_id
    
    Returns:
        Dict mapping base_id to CustomerRecord
    """
    customers = {}
    insert_pattern = re.compile(r"INSERT INTO `client` \([^)]+\) VALUES")
    
    print(f"Reading {filepath}...", file=sys.stderr)
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all INSERT statements
    inserts = insert_pattern.split(content)[1:]  # Skip first split (before first INSERT)
    
    total_rows = 0
    for insert_block in inserts:
        # Extract values - they end with semicolon
        values_match = re.search(r'^(.*?);', insert_block, re.DOTALL)
        if not values_match:
            continue
            
        values_text = values_match.group(1)
        
        # Parse individual rows - format: (id, name, goldtype, gold, money, ...)
        # Using regex to handle quoted strings with commas
        row_pattern = re.compile(
            r"\((\d+),\s*'([^']*(?:''[^']*)*)',\s*(\d+),\s*'([-\d.]+)',\s*'([-\d.]+)',\s*"
            r"(\d+),\s*'([^']*)',\s*(?:NULL|'([^']*)'),\s*'([-\d.]+)',\s*(-?\d+),\s*"
            r"'([^']*(?:''[^']*)*)',\s*(\d+),\s*(\d+)\)"
        )
        
        for match in row_pattern.finditer(values_text):
            total_rows += 1
            row_id = int(match.group(1))
            name = match.group(2).replace("''", "'")  # Unescape quotes
            goldtype = int(match.group(3))
            gold = Decimal(match.group(4))
            money = Decimal(match.group(5))
            date_str = match.group(7)
            base = match.group(11).replace("''", "'")  # Unescape quotes
            base_id = int(match.group(12))
            
            # Create or update customer record
            if base_id not in customers:
                customers[base_id] = CustomerRecord(base_id, base)
            
            customers[base_id].add_row(goldtype, gold, money, date_str)
    
    print(f"Parsed {total_rows} MySQL rows into {len(customers)} customers", file=sys.stderr)
    return customers


def handle_duplicate_names(customers: Dict[int, CustomerRecord]) -> List[CustomerRecord]:
    """
    Handle duplicate base names by appending (2), (3), etc.
    
    Returns:
        List of CustomerRecord with unique names
    """
    name_counts = defaultdict(int)
    result = []
    
    # Sort by base_id for consistent ordering
    for base_id in sorted(customers.keys()):
        customer = customers[base_id]
        base_name = customer.base_name
        
        name_counts[base_name] += 1
        if name_counts[base_name] > 1:
            customer.base_name = f"{base_name} ({name_counts[base_name]})"
            print(f"Warning: Duplicate base name '{base_name}' - renamed to '{customer.base_name}'", 
                  file=sys.stderr)
        
        result.append(customer)
    
    return result


def generate_postgresql_sql(customers: List[CustomerRecord]) -> str:
    """Generate PostgreSQL INSERT statements"""
    
    sql_parts = [
        "-- Migrated customer data from yuhuad2.sql",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- Total customers: {len(customers)}",
        "",
        "-- Clear existing data",
        "TRUNCATE TABLE customer RESTART IDENTITY CASCADE;",
        "",
        "-- Insert customer data",
        "INSERT INTO customer (name, money, gram_jewelry, baht_jewelry, gram_bar96, baht_bar96, gram_bar99, baht_bar99, created_at, updated_at)",
        "VALUES"
    ]
    
    # Generate VALUES clauses
    values_clauses = [customer.to_sql_values() for customer in customers]
    sql_parts.append(",\n".join(values_clauses))
    sql_parts.append(";")
    sql_parts.append("")
    
    return "\n".join(sql_parts)


def validate_data(customers: List[CustomerRecord]) -> Tuple[bool, List[str]]:
    """
    Validate customer data for potential issues
    
    Returns:
        (is_valid, list_of_warnings)
    """
    warnings = []
    
    for customer in customers:
        # Check for missing data
        if customer.row_count == 0:
            warnings.append(f"Customer '{customer.base_name}' has no rows")
        
        # Check for incomplete goldtype coverage
        if customer.row_count < 3:
            warnings.append(
                f"Customer '{customer.base_name}' has only {customer.row_count} goldtype(s) "
                f"(expected 3)"
            )
        
        # Check for extreme values
        if abs(customer.money) > 100000000:  # 100M
            warnings.append(
                f"Customer '{customer.base_name}' has extreme money value: {customer.money}"
            )
        
        if abs(customer.gram_jewelry) > 100000:  # 100kg
            warnings.append(
                f"Customer '{customer.base_name}' has extreme jewelry value: {customer.gram_jewelry}g"
            )
    
    return len(warnings) == 0, warnings


def insert_to_postgresql(customers: List[CustomerRecord], args):
    """Directly insert data into PostgreSQL database"""
    try:
        import psycopg2
        from psycopg2.extras import execute_values
    except ImportError:
        print("Error: psycopg2 not installed. Run: pip install psycopg2-binary", file=sys.stderr)
        sys.exit(1)
    
    print(f"Connecting to PostgreSQL via {args.db_host}...", file=sys.stderr)
    
    # Build connection parameters
    conn_params = {
        'host': args.db_host,
        'database': args.db_name,
        'user': args.db_user,
        'password': args.db_pass
    }
    
    # Only add port if specified (Unix socket doesn't need port)
    if args.db_port:
        conn_params['port'] = args.db_port
    
    conn = psycopg2.connect(**conn_params)
    
    try:
        with conn.cursor() as cur:
            # Clear existing data
            print("Truncating customer table...", file=sys.stderr)
            cur.execute("TRUNCATE TABLE customer RESTART IDENTITY CASCADE")
            
            # Prepare data for bulk insert
            data = []
            for customer in customers:
                updated_at = customer.latest_date if customer.latest_date else datetime.now()
                data.append((
                    customer.base_name,
                    customer.money,
                    customer.gram_jewelry,
                    Decimal('0.000'),  # baht_jewelry
                    customer.gram_bar96,
                    Decimal('0.000'),  # baht_bar96
                    customer.gram_bar99,
                    Decimal('0.000'),  # baht_bar99
                    datetime.now(),    # created_at
                    updated_at         # updated_at
                ))
            
            # Bulk insert
            print(f"Inserting {len(data)} customers...", file=sys.stderr)
            execute_values(
                cur,
                """
                INSERT INTO customer 
                (name, money, gram_jewelry, baht_jewelry, gram_bar96, baht_bar96, 
                 gram_bar99, baht_bar99, created_at, updated_at)
                VALUES %s
                """,
                data
            )
            
            conn.commit()
            print(f"✅ Successfully inserted {len(data)} customers", file=sys.stderr)
            
    finally:
        conn.close()


def main():
    parser = argparse.ArgumentParser(
        description='Migrate MySQL yuhuad2.sql to PostgreSQL customer table',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('input_file', help='Input MySQL dump file (yuhuad2.sql)')
    parser.add_argument('--output', '-o', help='Output SQL file (default: stdout)')
    parser.add_argument('--direct', action='store_true', 
                       help='Insert directly to PostgreSQL')
    parser.add_argument('--db-host', default='.pgdata', help='PostgreSQL socket directory or host')
    parser.add_argument('--db-port', type=int, default=None, help='PostgreSQL port (only for TCP)')
    parser.add_argument('--db-name', default='huatkimhang', help='Database name')
    parser.add_argument('--db-user', default='postgres', help='Database user')
    parser.add_argument('--db-pass', default='postgres', help='Database password')
    parser.add_argument('--validate-only', action='store_true',
                       help='Only validate data without generating output')
    parser.add_argument('--show-warnings', action='store_true',
                       help='Show all validation warnings')
    
    args = parser.parse_args()
    
    # Parse MySQL dump
    try:
        customers_dict = parse_mysql_dump(args.input_file)
    except FileNotFoundError:
        print(f"Error: File '{args.input_file}' not found", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error parsing MySQL dump: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Handle duplicate names
    customers = handle_duplicate_names(customers_dict)
    
    # Validate data
    is_valid, warnings = validate_data(customers)
    
    if warnings and args.show_warnings:
        print("\nValidation warnings:", file=sys.stderr)
        for warning in warnings[:20]:  # Show first 20
            print(f"  ⚠️  {warning}", file=sys.stderr)
        if len(warnings) > 20:
            print(f"  ... and {len(warnings) - 20} more warnings", file=sys.stderr)
    
    if args.validate_only:
        print(f"\n✅ Validation complete: {len(customers)} customers, {len(warnings)} warnings", 
              file=sys.stderr)
        sys.exit(0)
    
    # Generate output
    if args.direct:
        insert_to_postgresql(customers, args)
    else:
        sql = generate_postgresql_sql(customers)
        
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(sql)
            print(f"✅ SQL written to {args.output}", file=sys.stderr)
        else:
            print(sql)


if __name__ == '__main__':
    main()
