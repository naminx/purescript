--
-- PostgreSQL database dump
--

\restrict am1URVFHfiFxXCEJ4I1gxP2mFRbYjyJyvYO2VR01VisfbPOkuaCdCQF6fXGlgVs

-- Dumped from database version 16.11 (Debian 16.11-1.pgdg13+1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: balance_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.balance_type AS ENUM (
    'jewel',
    'bar96',
    'bar99'
);


ALTER TYPE public.balance_type OWNER TO postgres;

--
-- Name: group_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.group_type AS ENUM (
    'tray',
    'pack',
    'transaction'
);


ALTER TYPE public.group_type OWNER TO postgres;

--
-- Name: shape_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.shape_type AS ENUM (
    'jewelry',
    'bar'
);


ALTER TYPE public.shape_type OWNER TO postgres;

--
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.transaction_type AS ENUM (
    'prev_debit_money',
    'prev_credit_money',
    'prev_debit_jewel',
    'prev_credit_jewel',
    'prev_debit_bar96',
    'prev_credit_bar96',
    'prev_debit_bar99',
    'prev_credit_bar99',
    'money_in',
    'money_out',
    'jewel_in',
    'jewel_out',
    'bar96_in',
    'bar96_out',
    'bar99_in',
    'bar99_out',
    'buy_jewel',
    'sell_jewel',
    'buy_bar96',
    'sell_bar96',
    'buy_bar99',
    'sell_bar99',
    'convert_jewel_to_bar96',
    'convert_bar96_to_jewel',
    'convert_grams_to_baht',
    'convert_baht_to_grams',
    'split_bar'
);


ALTER TYPE public.transaction_type OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bill_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bill_groups (
    id integer NOT NULL,
    bill_id integer NOT NULL,
    group_type public.group_type NOT NULL,
    display_order integer NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    updated_by character varying(100),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.bill_groups OWNER TO postgres;

--
-- Name: TABLE bill_groups; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.bill_groups IS 'Groups within a bill (trays, packs, transactions)';


--
-- Name: bill_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bill_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bill_groups_id_seq OWNER TO postgres;

--
-- Name: bill_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bill_groups_id_seq OWNED BY public.bill_groups.id;


--
-- Name: bills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bills (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    date timestamp without time zone DEFAULT now() NOT NULL,
    prev_balance_money numeric(12,2) NOT NULL,
    prev_gram_jewel numeric(10,3) NOT NULL,
    prev_baht_jewel numeric(10,3) NOT NULL,
    prev_gram_bar96 numeric(10,3) NOT NULL,
    prev_baht_bar96 numeric(10,3) NOT NULL,
    prev_gram_bar99 numeric(10,3) NOT NULL,
    prev_baht_bar99 numeric(10,3) NOT NULL,
    final_balance_money numeric(12,2),
    final_gram_jewel numeric(10,3),
    final_baht_jewel numeric(10,3),
    final_gram_bar96 numeric(10,3),
    final_baht_bar96 numeric(10,3),
    final_gram_bar99 numeric(10,3),
    final_baht_bar99 numeric(10,3),
    is_vat_deferred boolean DEFAULT true NOT NULL,
    vat_rate numeric(5,2) DEFAULT 7.00 NOT NULL,
    market_buying_price_jewel numeric(12,2),
    vat_taxable_amount numeric(12,2),
    vat_amount numeric(12,2),
    is_finalized boolean DEFAULT false NOT NULL,
    finalized_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    version integer DEFAULT 1 NOT NULL
);


ALTER TABLE public.bills OWNER TO postgres;

--
-- Name: TABLE bills; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.bills IS 'Customer bills with previous and final balances';


--
-- Name: COLUMN bills.is_vat_deferred; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.bills.is_vat_deferred IS 'TRUE = VAT deferred (default), FALSE = VAT taxable';


--
-- Name: COLUMN bills.market_buying_price_jewel; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.bills.market_buying_price_jewel IS 'Announced price by Gold Traders Association (jewelry only)';


--
-- Name: bills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bills_id_seq OWNER TO postgres;

--
-- Name: bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bills_id_seq OWNED BY public.bills.id;


--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    money numeric(15,2) DEFAULT 0.00 NOT NULL,
    gram_jewelry numeric(15,3) DEFAULT 0.000 NOT NULL,
    baht_jewelry numeric(15,3) DEFAULT 0.000 NOT NULL,
    gram_bar96 numeric(15,3) DEFAULT 0.000 NOT NULL,
    baht_bar96 numeric(15,3) DEFAULT 0.000 NOT NULL,
    gram_bar99 numeric(15,3) DEFAULT 0.000 NOT NULL,
    baht_bar99 numeric(15,3) DEFAULT 0.000 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_id_seq OWNER TO postgres;

--
-- Name: customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_id_seq OWNED BY public.customer.id;


--
-- Name: jewelry_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jewelry_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.jewelry_types OWNER TO postgres;

--
-- Name: jewelry_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jewelry_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jewelry_types_id_seq OWNER TO postgres;

--
-- Name: jewelry_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jewelry_types_id_seq OWNED BY public.jewelry_types.id;


--
-- Name: nominal_weights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nominal_weights (
    id integer NOT NULL,
    label character varying(10) NOT NULL,
    weight_grams numeric(6,3) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.nominal_weights OWNER TO postgres;

--
-- Name: pack_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pack_items (
    id integer NOT NULL,
    pack_id integer NOT NULL,
    display_order integer NOT NULL,
    deduction_rate character varying(20) NOT NULL,
    shape public.shape_type NOT NULL,
    purity numeric(6,3),
    description character varying(255),
    weight_grams numeric(10,3),
    weight_baht numeric(10,3),
    calculation_amount numeric(12,2) NOT NULL,
    CONSTRAINT pack_items_check CHECK ((((weight_grams IS NOT NULL) AND (weight_baht IS NULL)) OR ((weight_grams IS NULL) AND (weight_baht IS NOT NULL))))
);


ALTER TABLE public.pack_items OWNER TO postgres;

--
-- Name: TABLE pack_items; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.pack_items IS 'Individual items within a pack';


--
-- Name: pack_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pack_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pack_items_id_seq OWNER TO postgres;

--
-- Name: pack_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pack_items_id_seq OWNED BY public.pack_items.id;


--
-- Name: packs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.packs (
    id integer NOT NULL,
    group_id integer NOT NULL,
    internal_id integer NOT NULL,
    user_number character varying(50) NOT NULL
);


ALTER TABLE public.packs OWNER TO postgres;

--
-- Name: TABLE packs; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.packs IS 'Pack groups for used gold brought by customer';


--
-- Name: packs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.packs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.packs_id_seq OWNER TO postgres;

--
-- Name: packs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.packs_id_seq OWNED BY public.packs.id;


--
-- Name: transaction_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction_items (
    id integer NOT NULL,
    transaction_id integer NOT NULL,
    display_order integer NOT NULL,
    transaction_type public.transaction_type NOT NULL,
    amount_money numeric(12,2),
    amount_grams numeric(10,3),
    amount_baht numeric(10,3),
    balance_type public.balance_type,
    price_rate numeric(12,2),
    conversion_charge_rate numeric(12,2),
    split_charge_rate numeric(12,2),
    block_making_charge_rate numeric(12,2),
    source_amount_grams numeric(10,3),
    source_amount_baht numeric(10,3),
    dest_amount_grams numeric(10,3),
    dest_amount_baht numeric(10,3),
    CONSTRAINT transaction_items_check CHECK ((((amount_grams IS NOT NULL) AND (amount_baht IS NULL)) OR ((amount_grams IS NULL) AND (amount_baht IS NOT NULL)) OR ((amount_grams IS NULL) AND (amount_baht IS NULL))))
);


ALTER TABLE public.transaction_items OWNER TO postgres;

--
-- Name: TABLE transaction_items; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.transaction_items IS 'Individual transactions';


--
-- Name: COLUMN transaction_items.amount_grams; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.transaction_items.amount_grams IS 'Gold amount in grams (mutually exclusive with amount_baht)';


--
-- Name: COLUMN transaction_items.amount_baht; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.transaction_items.amount_baht IS 'Gold amount in baht (mutually exclusive with amount_grams)';


--
-- Name: COLUMN transaction_items.block_making_charge_rate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.transaction_items.block_making_charge_rate IS 'Block mold cost for small bars (THB/baht), VAT INCLUSIVE';


--
-- Name: transaction_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaction_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transaction_items_id_seq OWNER TO postgres;

--
-- Name: transaction_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transaction_items_id_seq OWNED BY public.transaction_items.id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: TABLE transactions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.transactions IS 'Transaction groups for money/gold movements';


--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_id_seq OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: tray_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tray_items (
    id integer NOT NULL,
    tray_id integer NOT NULL,
    display_order integer NOT NULL,
    making_charge integer NOT NULL,
    jewelry_type_id integer,
    design_name character varying(255),
    nominal_weight numeric(6,3) NOT NULL,
    quantity integer NOT NULL,
    amount integer NOT NULL,
    nominal_weight_id integer,
    CONSTRAINT tray_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.tray_items OWNER TO postgres;

--
-- Name: TABLE tray_items; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tray_items IS 'Individual items within a tray';


--
-- Name: tray_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tray_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tray_items_id_seq OWNER TO postgres;

--
-- Name: tray_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tray_items_id_seq OWNED BY public.tray_items.id;


--
-- Name: trays; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trays (
    id integer NOT NULL,
    group_id integer NOT NULL,
    internal_num integer NOT NULL,
    is_return boolean DEFAULT false NOT NULL,
    purity numeric(6,3),
    shape public.shape_type NOT NULL,
    discount integer DEFAULT 0,
    actual_weight_grams numeric(10,3) NOT NULL,
    price_rate numeric(12,2),
    additional_charge_rate numeric(12,2),
    CONSTRAINT trays_discount_check CHECK ((discount = ANY (ARRAY[0, 5, 10])))
);


ALTER TABLE public.trays OWNER TO postgres;

--
-- Name: TABLE trays; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.trays IS 'Tray groups for new jewelry purchases';


--
-- Name: COLUMN trays.additional_charge_rate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.trays.additional_charge_rate IS '99.99% premium rate (THB/baht), MUST be set if purity > 96.5%';


--
-- Name: trays_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trays_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trays_id_seq OWNER TO postgres;

--
-- Name: trays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trays_id_seq OWNED BY public.trays.id;


--
-- Name: bill_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill_groups ALTER COLUMN id SET DEFAULT nextval('public.bill_groups_id_seq'::regclass);


--
-- Name: bills id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills ALTER COLUMN id SET DEFAULT nextval('public.bills_id_seq'::regclass);


--
-- Name: customer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer ALTER COLUMN id SET DEFAULT nextval('public.customer_id_seq'::regclass);


--
-- Name: jewelry_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jewelry_types ALTER COLUMN id SET DEFAULT nextval('public.jewelry_types_id_seq'::regclass);


--
-- Name: pack_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_items ALTER COLUMN id SET DEFAULT nextval('public.pack_items_id_seq'::regclass);


--
-- Name: packs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packs ALTER COLUMN id SET DEFAULT nextval('public.packs_id_seq'::regclass);


--
-- Name: transaction_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_items ALTER COLUMN id SET DEFAULT nextval('public.transaction_items_id_seq'::regclass);


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Name: tray_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tray_items ALTER COLUMN id SET DEFAULT nextval('public.tray_items_id_seq'::regclass);


--
-- Name: trays id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trays ALTER COLUMN id SET DEFAULT nextval('public.trays_id_seq'::regclass);


--
-- Data for Name: bill_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bill_groups (id, bill_id, group_type, display_order, version, updated_by, created_at, updated_at) FROM stdin;
5	10	tray	1	1	\N	2025-11-23 18:06:24.596428	2025-11-23 18:06:24.596428
6	10	transaction	2	1	\N	2025-11-23 18:06:24.600101	2025-11-23 18:06:24.600101
7	11	pack	1	1	\N	2025-11-23 18:06:24.602895	2025-11-23 18:06:24.602895
8	11	transaction	2	1	\N	2025-11-23 18:06:24.604443	2025-11-23 18:06:24.604443
9	20	tray	1	1	\N	2025-11-23 18:06:54.470772	2025-11-23 18:06:54.470772
10	20	transaction	2	1	\N	2025-11-23 18:06:54.476909	2025-11-23 18:06:54.476909
11	21	pack	1	1	\N	2025-11-23 18:06:54.482082	2025-11-23 18:06:54.482082
12	21	transaction	2	1	\N	2025-11-23 18:06:54.48592	2025-11-23 18:06:54.48592
13	30	tray	1	1	\N	2025-11-23 18:07:25.096938	2025-11-23 18:07:25.096938
14	30	transaction	2	1	\N	2025-11-23 18:07:25.104397	2025-11-23 18:07:25.104397
15	31	pack	1	1	\N	2025-11-23 18:07:25.111762	2025-11-23 18:07:25.111762
16	31	transaction	2	1	\N	2025-11-23 18:07:25.119058	2025-11-23 18:07:25.119058
\.


--
-- Data for Name: bills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bills (id, customer_id, date, prev_balance_money, prev_gram_jewel, prev_baht_jewel, prev_gram_bar96, prev_baht_bar96, prev_gram_bar99, prev_baht_bar99, final_balance_money, final_gram_jewel, final_baht_jewel, final_gram_bar96, final_baht_bar96, final_gram_bar99, final_baht_bar99, is_vat_deferred, vat_rate, market_buying_price_jewel, vat_taxable_amount, vat_amount, is_finalized, finalized_at, created_at, updated_at, version) FROM stdin;
2	1	2025-11-23 00:00:00	1000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30000.00	\N	\N	f	\N	2025-11-23 18:04:39.044958	2025-11-23 18:04:39.044958	1
3	2	2025-11-23 00:00:00	50000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30500.00	\N	\N	f	\N	2025-11-23 18:04:39.047709	2025-11-23 18:04:39.047709	1
10	1	2025-11-23 00:00:00	1000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30000.00	\N	\N	f	\N	2025-11-23 18:06:24.595007	2025-11-23 18:06:24.595007	1
11	2	2025-11-23 00:00:00	50000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30500.00	\N	\N	f	\N	2025-11-23 18:06:24.60162	2025-11-23 18:06:24.60162	1
20	1	2025-11-23 00:00:00	1000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30000.00	\N	\N	f	\N	2025-11-23 18:06:54.469318	2025-11-23 18:06:54.469318	1
21	2	2025-11-23 00:00:00	50000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30500.00	\N	\N	f	\N	2025-11-23 18:06:54.480103	2025-11-23 18:06:54.480103	1
30	1	2025-11-23 00:00:00	1000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30000.00	\N	\N	f	\N	2025-11-23 18:07:25.095212	2025-11-23 18:07:25.095212	1
31	2	2025-11-23 00:00:00	50000.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	f	7.00	30500.00	\N	\N	f	\N	2025-11-23 18:07:25.109546	2025-11-23 18:07:25.109546	1
4	1	2025-11-23 19:02:43.555066	0.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	t	7.00	\N	\N	\N	f	\N	2025-11-23 19:02:43.555066	2025-11-23 19:02:43.555066	1
5	1	2025-11-24 14:59:57.150191	0.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	t	7.00	\N	\N	\N	f	\N	2025-11-24 14:59:57.150191	2025-11-24 15:00:03.413919	2
6	1	2025-11-25 13:09:30.659805	0.00	0.000	0.000	0.000	0.000	0.000	0.000	\N	\N	\N	\N	\N	\N	\N	t	7.00	\N	\N	\N	f	\N	2025-11-25 13:09:30.659805	2025-11-25 13:09:30.659805	1
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (id, name, money, gram_jewelry, baht_jewelry, gram_bar96, baht_bar96, gram_bar99, baht_bar99, created_at, updated_at) FROM stdin;
1	เจ๊หมวยเล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145241	2012-12-28 12:13:59
2	เยาวราชบางปะกอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145265	2025-09-30 18:16:31
3	จังเจริญชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145268	2025-06-05 13:45:03
5	ทองประเสริฐ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145273	2017-01-12 16:29:31
7	เอ็มทีเอส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145276	2009-12-11 16:36:13
8	ตั๊กเซ่งล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145278	2013-07-17 16:12:11
9	สุดารัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14528	2024-03-08 14:30:07
10	คุณมาลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145282	2022-03-05 10:47:59
11	คุณซ้อสุสติ๊กเกอร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145283	2013-04-27 11:48:31
12	โชคชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145284	2020-08-14 16:53:48
13	นายห้างโกวิทย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145286	2025-10-21 13:46:22
14	ศรีสุพรรณสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145288	2025-09-20 14:52:35
15	จีจี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145289	2009-12-11 14:46:23
16	ปน3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145291	2022-10-27 14:36:04
17	กิมเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145292	2019-10-01 14:12:32
18	แก้วมณีปากน้ำ	-190997.34	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145298	2025-10-16 16:27:33
19	โต๊ะกังแจ้งพ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1453	2009-11-04 00:00:00
20	พรประสิทธิ์	0.00	193.700	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145301	2025-10-11 12:00:07
21	แซมฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145303	2025-09-27 09:54:06
22	*สง่าเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145304	2011-04-28 00:00:00
23	ปน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145305	2025-05-20 15:15:34
24	เพชรเมืองทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145307	2022-12-21 15:53:52
25	เทพทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145308	2025-10-11 14:32:07
26	พนักงานหน่อบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14531	2010-04-10 00:00:00
27	เจ็กเล็กวรวัฒน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145311	2010-07-07 15:06:44
28	สันต์ฤทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145312	2017-10-24 16:16:39
29	ย่งเชียงล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145314	2019-05-02 18:05:30
30	โชคดีสุทธิสาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145317	2025-03-26 16:32:52
31	โชคดีดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145318	2025-10-19 10:01:19
32	โต๊ะกังแจ้งวัฒนะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14532	2024-02-07 13:23:17
33	ดาวทองมหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145321	2025-09-16 09:42:15
34	ดาวทองบางปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145322	2025-10-08 14:32:18
35	ฉลองชัยหันคา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145324	2025-10-18 10:27:30
36	คุณผึ้งmmp	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145325	2011-04-02 09:07:58
37	คุณยศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145327	2017-08-20 13:14:35
38	นิมิตรโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145328	2016-02-11 12:46:25
39	อาม่าคุณวรรณา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14533	2020-01-09 11:31:37
40	คุณวรรณา825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145331	2017-09-07 15:49:18
41	กุลเมืองใหม่	0.00	0.000	0.000	2896.350	0.000	0.000	0.000	2025-11-20 15:38:54.145332	2025-10-02 12:03:54
42	ทองวิจิตรแม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145336	2011-12-18 10:00:28
43	สินสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145337	2025-01-10 14:24:29
44	แม่สุจินต์ ด่านช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145338	2025-02-27 13:24:44
45	ฮะเซ่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14534	2014-12-25 00:00:00
46	วาเลนไทน์(ลำปาง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145342	2025-10-09 10:38:53
47	ตั๊กเซ่งฮง	-119205890.67	0.000	0.000	-3048.800	0.000	0.000	0.000	2025-11-20 15:38:54.145343	2025-10-26 11:36:12
48	เยาวราชฉลองกรุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145344	2022-10-09 11:29:33
49	แม่ทองสุกสระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145346	2025-02-01 16:56:47
50	เยาวราชฉลองกรุง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145347	2025-04-03 12:32:49
51	เชียงเส็ง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145348	2025-05-08 09:50:26
52	ดำรงค์ชัยอิม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145349	2023-02-11 15:26:33
53	ปลีก1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145351	2025-10-26 13:47:56
54	เยาวราชบางเมือง	0.00	0.000	0.000	1524.450	0.000	0.000	0.000	2025-11-20 15:38:54.145354	2025-10-24 15:44:06
55	เตียวเซ่งเฮงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145355	2025-09-25 15:08:08
56	ฮั้งจิว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145356	2017-01-18 12:19:05
57	แม่จอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145357	2025-08-27 10:06:27
58	ดีเฮง	-1646729.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145359	2025-10-26 14:31:37
59	เยาวราชนวนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14536	2023-10-17 12:13:06
60	ไท้เซ่งฮงหาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145361	2025-10-17 16:47:07
61	เอี๊ยะง้วน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145362	2024-03-07 15:15:30
62	ร้านแม่พรแม่ริม	0.00	0.000	0.000	2591.550	0.000	0.000	0.000	2025-11-20 15:38:54.145364	2025-10-25 10:54:27
63	มหางาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145367	2025-10-22 15:19:55
64	แสงสุวรรณนางเลิ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145368	2020-04-08 10:33:15
65	วรรณวิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145369	2018-10-12 16:38:16
66	เหรียญทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145372	2019-07-31 15:38:02
67	100%ท่าม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145373	2024-10-06 12:15:45
68	รัตนกิจศรีย่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145375	2023-04-05 13:09:18
69	บุญสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145377	2016-10-27 00:00:00
70	สายอุทัยเชียงราย	0.00	0.000	0.000	1524.400	0.000	0.000	0.000	2025-11-20 15:38:54.145379	2025-10-17 17:12:30
71	เนื้อดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14538	2024-05-07 16:35:35
72	ตระกูลทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145381	2016-09-30 00:00:00
73	ฮั้วชุนเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145382	2013-11-14 00:00:00
74	เทพ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145383	2016-05-24 10:16:01
75	คุณแอร์VS	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145385	2015-09-24 14:10:49
76	ทรายทอง	0.00	8.050	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145386	2025-08-30 14:48:09
6	จังเจริญชัยเจ๊	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145274	2025-11-20 15:41:50.582675
3999	9 ทองเยาวราช บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151862	2025-11-20 15:44:25.655964
77	จินดามีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145387	2022-12-22 14:59:29
78	จิ้นฮั้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145391	2009-11-19 00:00:00
79	จิบเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145392	2025-08-05 16:09:50
80	จิรสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145393	2012-09-02 14:47:35
81	จิวเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145394	2025-06-20 15:55:06
82	จึงเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145396	2011-09-06 00:00:00
83	mcเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145397	2009-11-19 00:00:00
84	คุณณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145399	2022-06-19 12:35:55
85	เจริญทอง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1454	2025-08-15 13:41:13
86	เจริญทอง3	0.00	79.400	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145401	2025-10-25 15:21:11
87	เจริญมณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145402	2014-05-12 00:00:00
88	เจริญยิ่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145403	2013-08-17 00:00:00
89	เจริญศรีสวัสดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145405	2009-11-19 00:00:00
90	กรกช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145407	2015-04-02 00:00:00
91	เจริญแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145409	2009-11-19 00:00:00
92	กรรณิการ์อู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14541	2025-02-28 15:14:29
93	เจ้สม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145411	2010-10-16 15:41:19
94	เจียมเซ่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145413	2025-10-17 12:38:39
95	โจวเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145414	2024-12-07 09:25:22
96	ฉั่นไท้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145415	2024-01-26 10:54:59
97	กิตติพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145417	2025-05-23 14:24:11
98	กิตติยาจอมบึง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145418	2025-09-23 09:29:20
99	กิมฝ่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145419	2012-08-08 00:00:00
100	กุลศรีสุวรรณช้างเผือก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145421	2019-11-02 14:21:07
101	กุลศรีสุวรรณตลาดเมืองใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145423	2025-03-26 14:01:43
102	กุลศรีสุวรรณวิทยาลัยครู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145426	2019-07-02 15:42:03
103	กุหลาบทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145427	2013-01-15 00:00:00
104	แก้วมณีบ้านโป่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145428	2018-09-10 16:20:45
105	แก้วมณีปากน้ำสาขา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145429	2025-09-16 15:41:28
106	โกลด์เซ็นเตอร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145431	2018-04-20 16:47:44
107	ศรีทองปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145432	2025-08-01 15:55:23
108	คำทิพย์	0.00	0.000	0.000	19817.200	0.000	0.000	0.000	2025-11-20 15:38:54.145433	2025-04-18 14:58:19
109	เคียนฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145435	2025-02-27 09:20:51
110	เคียนฮวดเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145436	2017-12-23 14:49:23
111	ง้วนลีเส็ง เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145437	2015-12-22 00:00:00
112	งามเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145438	2017-04-21 16:18:27
113	โง้วฮงฮั้วปากน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145439	2019-05-14 15:55:58
114	จงเจริญท่าม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145442	2025-09-07 14:08:44
115	จงถุ่งชุน1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145443	2025-10-24 17:18:43
116	จงถุ่งชุน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145445	2024-01-19 11:41:55
117	จงถุ่งชุน3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145446	2025-10-18 12:43:57
118	จงถุ่งชุน4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145447	2025-10-22 17:22:58
119	จงถุ่งชุน5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145448	2022-12-10 12:24:01
120	จงถุ่งชุน6	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14545	2025-06-05 09:05:47
121	เยาวราชโกลด์จิวเวลรี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145451	2009-11-19 00:00:00
122	ดำรงชัยกิ่งแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145452	2025-04-03 12:02:57
123	ดีดีดำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145454	2025-04-23 10:06:16
124	ดีเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145455	2013-02-19 14:14:40
125	ดีดีเอ็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145456	2023-10-18 09:14:14
126	ตะวันนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145459	2025-10-15 09:43:44
127	ตันง่วนไถ่3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14546	2019-08-10 11:39:04
128	ตั้งเซ่งเฮง ลำนารายณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145461	2024-07-16 11:17:33
129	ตันง่วนไถ่2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145462	2024-10-08 14:01:41
130	ตันง่วนไถ่5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145464	2025-06-07 11:06:40
131	รุ้งเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145465	2009-11-19 00:00:00
132	เตี่ยเซ่งเฮงแปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145467	2025-05-07 08:43:22
133	ทองเซ็นเตอร์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145469	2021-04-01 13:57:41
134	แต้เซ่งเฮงลำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14547	2025-08-27 10:35:14
135	เซ่งเฮงห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145472	2010-11-11 00:00:00
136	โต๊ะกังกบินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145473	2025-10-18 12:22:48
137	โต๊ะกังท่าพระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145474	2021-02-27 16:31:21
138	โต๊ะกังรังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145477	2016-02-17 16:24:25
139	ทรงศิริ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145478	2010-10-19 00:00:00
140	ทรงสุวรรณกิจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145479	2022-03-09 15:20:10
141	ทรัพย์สุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145481	2017-08-05 12:58:18
142	ทวีทรัพย์บางบ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145482	2009-11-19 11:42:27
143	ทวีทรัพย์ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145483	2009-11-19 11:42:58
144	ทองส.เจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145484	2020-10-24 09:48:59
145	ทองเจริญสุข	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145485	2025-10-02 11:20:04
146	ชัยสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145486	2023-10-05 11:46:39
147	ซุนเฮงหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145489	2014-11-16 00:00:00
148	ซิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14549	2016-09-28 13:31:12
149	ซินฟุงลี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145492	2009-11-19 11:49:33
150	ซุ้ยฮั้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145493	2024-07-25 13:59:55
151	แซ่ฮั้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145495	2010-05-12 15:08:19
152	ศิริมาศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145496	2009-11-19 00:00:00
153	ดารา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145497	2016-07-07 15:38:55
154	เพชรทองเยาวราชแปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145498	2019-12-03 16:25:25
155	เพชรนิพนธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1455	2012-07-05 11:41:08
156	เพชรไพลิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145501	2012-04-11 10:32:58
157	เพชรไพลิน9	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145502	2024-11-16 10:34:59
158	เพชรมณีปากอ่าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145504	2009-11-19 00:00:00
159	ทองทิพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145505	2009-11-19 11:56:33
160	เพชรวิฑูร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145506	2023-05-20 12:57:17
161	เพียวพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145507	2011-03-08 08:57:54
162	ฟู่ฮุยเส็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145508	2009-11-19 11:58:04
163	โภควัฒนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145511	2009-11-19 00:00:00
164	มณีทิพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145513	2009-11-19 00:00:00
165	มณีงาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145514	2009-11-19 00:00:00
166	มังกรคู่นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145516	2016-10-19 13:31:37
167	มังกรคู่แม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145517	2016-09-29 15:33:26
168	ทองไทยโคกสำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145518	2025-05-06 14:57:14
169	มังกรฟ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145519	2025-07-23 13:07:12
170	เสกสรร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14552	2009-11-19 00:00:00
171	แม่กิมกี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145521	2025-07-14 13:40:51
172	แม่กิมซ่วน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145523	2009-11-19 00:00:00
173	ตั้งโต๊ะกังบางรัก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145524	2025-10-24 09:24:05
174	ทองประพันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145525	2014-05-21 15:53:28
175	ไทยเจริญ กำแพงพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145528	2025-07-22 15:28:45
176	ไทยทวี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145529	2023-10-20 08:54:38
177	ไทยรังสิต2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14553	2013-03-08 00:00:00
178	รุ่งมณีลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145531	2018-07-09 10:31:03
179	ทองสมบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145532	2009-11-19 00:00:00
180	ทองสยามปากน้ำ	2000.00	0.000	0.000	1524.400	0.000	0.000	0.000	2025-11-20 15:38:54.145533	2025-10-25 08:54:40
181	ไทยรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145534	2025-08-19 10:57:42
182	ไทยรัตน์สาขา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145536	2009-11-19 00:00:00
183	ไทยศิริ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145537	2009-11-19 00:00:00
184	ไทยเฮงหลีบัวใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145538	2013-11-26 17:41:12
185	ทิพย์ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145539	2009-11-19 12:05:04
186	ไท้เส็งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14554	2009-11-19 00:00:00
187	ธนกิจสี่ย่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145542	2025-09-28 10:22:21
188	ธนาวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145543	2025-09-03 14:26:41
189	นงนุชสมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145545	2025-10-08 09:45:21
190	ทิพย์มณีอำนาจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145546	2024-11-22 11:56:17
191	เฮียนึกนวนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145547	2025-09-05 13:12:24
192	เทพนิมิต1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145548	2022-12-27 17:31:21
193	น้องแซมฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14555	2015-03-14 11:42:42
194	เทพพิทักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145551	2018-02-08 10:27:42
195	นันทชัยเชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145553	2022-04-16 11:36:47
196	นันทชัยเทิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145555	2023-10-11 15:58:07
197	ไท้เซ่งล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145556	2016-06-07 09:04:08
198	นำโชค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145558	2013-08-16 17:25:59
199	เนรมิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14556	2019-05-09 16:42:28
200	แม่กิมเย็น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145561	2013-03-28 00:00:00
201	แม่กิมเสียน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145562	2023-10-14 16:16:56
202	แม่กิมเอ็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145563	2019-12-20 18:05:05
203	แม่ซิ้วเตียน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145564	2025-10-18 11:45:00
204	แม่ซุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145565	2013-12-18 00:00:00
205	แม่ถุงเงิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145567	2022-03-23 16:18:16
206	แม่ทองใจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145568	2025-10-11 14:19:38
207	แม่ทิพย์5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145569	2009-11-19 00:00:00
208	แม่บัวตอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14557	2013-07-10 00:00:00
209	บรรจงพานิชย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145571	2017-06-02 15:46:38
210	แม่บุญมีเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145572	2009-11-19 00:00:00
211	แม่บุญรอดบิ๊กซี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145587	2022-03-30 16:09:04
212	แม่บุญเรือง	0.00	0.000	0.000	5792.750	0.000	0.000	0.000	2025-11-20 15:38:54.145589	2025-10-22 17:04:56
213	แม่เพียรทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145591	2025-06-20 14:28:57
214	แม่ยินดีแปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145593	2021-12-01 14:52:51
215	ประชาไท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145594	2016-02-13 11:53:48
216	แม่สมจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145596	2025-10-16 09:23:42
217	แม่สมัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145597	2025-07-12 10:37:18
218	ประทับใจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145599	2020-10-29 15:15:18
219	ประสงค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145601	2013-11-29 10:33:07
220	แม่ฮวย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145603	2025-02-10 14:25:52
221	ประเสริฐสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145605	2011-07-08 09:41:50
222	แม่เฮียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145607	2009-11-19 00:00:00
223	สุขทองใบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145611	2019-03-03 12:19:04
224	ศรีชัยเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145612	2018-08-10 16:39:15
225	ศรีพรชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145613	2019-05-07 16:20:20
226	พ.เลิศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145614	2009-11-19 00:00:00
227	เกาย่งฮั่ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145616	2009-11-19 00:00:00
228	ย่งเฮงหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145622	2023-03-01 16:38:16
229	พรประสิทธ์โกตา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145623	2009-11-19 00:00:00
230	ยี่เฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145624	2015-02-11 10:29:14
231	พิมลพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145625	2009-11-19 00:00:00
232	เพชรทองคำเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145628	2016-03-03 12:15:22
233	เพชรทองทองหล่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145629	2025-04-19 14:49:05
234	เพชรทองแม่สมัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145631	2019-01-08 12:20:55
235	เพชรทองชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145633	2009-11-19 00:00:00
236	ทองเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145635	2009-11-19 00:00:00
237	ยงดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145636	2009-11-19 00:00:00
238	เยาวราช9คลองสอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145637	2020-04-14 12:21:55
239	เยาวราช2หนามแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145639	2025-06-10 10:37:24
240	เยาวราชบางน้ำเปรี้ยว1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14564	2014-05-21 13:43:29
241	รุ่งเจริญท้ายบ้าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145641	2009-11-19 00:00:00
242	เยาวราชปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145642	2015-11-12 17:04:54
243	รุ่งทองใบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145644	2009-11-19 00:00:00
244	รุ่งฟ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145645	2022-06-17 12:21:28
245	รุ่งเรืองตาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145646	2019-09-28 17:23:41
246	รุ่งโรจน์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145647	2018-08-09 16:49:24
247	รุ่งโรจน์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14565	2017-02-16 17:26:24
248	รุ่งสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145651	2025-03-05 16:06:39
249	ลิ้มเซ่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145652	2024-10-24 15:05:22
250	วรรณดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145653	2009-11-19 00:00:00
251	ไล้ฮี้เซ้ง	0.00	15.600	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145655	2025-09-05 15:30:03
252	เยาวราช8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145656	2024-08-06 16:17:50
253	เยาวราชครุใน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145657	2020-06-24 16:37:20
254	เยาวราชคลองแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145658	2024-11-27 13:51:17
255	เยาวราชคลองด่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14566	2025-10-25 09:26:56
256	ศิรินันท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145661	2023-12-19 16:22:56
257	ศุภชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145662	2025-05-16 16:18:36
258	สมนึก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145663	2023-05-03 15:27:21
259	สรรค์ชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145666	2021-11-14 14:31:32
260	สายสังข์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145669	2009-11-19 00:00:00
261	วราภรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14567	2009-11-19 00:00:00
262	สายอุทัยเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145671	2016-03-16 15:01:14
263	สารช่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145672	2020-04-17 14:10:45
264	สิทธิโชค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145673	2021-03-10 16:51:59
265	วันดีพะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145675	2009-11-19 00:00:00
266	วิษณุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145676	2012-12-25 10:28:46
267	วีแอนด์วัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145677	2025-10-09 16:35:37
268	วีรพงษ์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145678	2016-07-08 09:29:41
269	สินอู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145679	2024-11-24 12:15:00
270	สุขดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145681	2022-11-24 13:17:23
271	สุขสมบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145683	2018-10-25 15:23:08
272	สุขสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145685	2025-09-04 16:29:32
273	สุพรรณกิจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145686	2016-09-22 12:21:42
274	สุพรรณช่าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145687	2013-05-02 13:30:34
275	สุพรรณหงส์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145688	2009-11-19 13:31:38
276	สุภาภรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14569	2012-03-01 16:20:15
277	สุวรรณพัฒนา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145691	2024-10-05 14:13:51
278	สุวรรณรัตน์เกาะช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145692	2014-08-23 13:39:33
279	สุวรรณศิลป์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145693	2016-10-05 13:25:39
280	เสริมเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145695	2025-10-24 13:00:11
281	เสรีภัณฑ์	0.00	0.000	0.000	3506.100	0.000	0.000	0.000	2025-11-20 15:38:54.145696	2025-10-25 08:45:56
282	แสงเจริญบางประกอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145698	2025-01-10 16:27:29
283	แสงชัยพระบาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1457	2025-09-18 12:54:19
284	แสงทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145702	2009-11-19 13:35:26
285	แสงทองใบสาขา3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145703	2024-12-01 13:46:09
286	แสงทองใบอ่อนนุช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145704	2022-11-15 16:01:38
287	แสงเพชรลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145705	2022-03-19 14:54:11
288	แสงรุ่งรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145706	2025-01-25 13:27:54
289	แสงวิมล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145707	2023-12-17 10:32:58
290	ศรีเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145709	2025-09-12 15:31:05
291	ศรีสวัสดิ์ทุ่งใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145711	2015-11-04 13:55:16
292	ศรีสุพรรณแม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145712	2025-01-14 08:46:05
293	เยาวราชแพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145713	2024-01-15 16:15:45
294	เยาวราชมังกรทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145715	2024-06-25 16:12:33
295	เยาวราชแม่แจ่ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145716	2022-05-15 09:42:05
296	เยาวราชแม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145719	2025-10-22 13:06:17
297	เยาวราชรังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14572	2025-04-03 12:56:00
298	เยาวราชศรีนครินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145721	2025-01-15 11:40:42
299	เยาวราชศรีบุญเรือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145722	2009-11-19 14:08:15
300	เยาวราชสำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145724	2025-10-18 12:37:38
301	เยาวราชอินทรารักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145725	2025-02-21 12:11:32
302	รวมเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145726	2024-12-13 16:51:12
303	รัตนกิจเทเวศน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145727	2016-03-18 14:49:31
304	รัตนสุวรรณ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145729	2025-04-18 13:52:57
305	รัศมีเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145729	2016-09-06 15:39:29
306	รัศมีเยาวราช2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14573	2009-11-19 14:17:18
307	ราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145731	2019-03-01 16:45:47
308	เยาวราชจอมบึง	0.00	0.000	0.000	56.450	0.000	0.000	0.000	2025-11-20 15:38:54.145734	2025-07-14 11:03:46
309	เยาวราชเชียงคำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145735	2019-01-05 09:10:12
310	อุมารินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145737	2013-08-14 17:08:28
311	เอกเซ่งเฮง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145738	2022-10-25 14:48:03
312	เอกเซ่งเฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145739	2022-03-23 09:21:01
313	เอกทองชุมแพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14574	2009-11-19 00:00:00
314	เอกมณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145741	2017-04-29 11:03:50
315	เอกสุวรรณ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145742	2025-03-22 16:11:11
316	เอราวัณด่านช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145744	2024-07-12 10:26:49
317	เยาวราชซังฮี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145746	2016-12-15 17:44:40
318	เยาวราชดอนกลาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145747	2019-12-08 12:52:47
319	เอี๋ยมฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145748	2025-07-23 09:32:59
320	เยาวราชต้น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145751	2024-11-16 14:03:19
321	เยาวราชเถิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145752	2023-08-25 13:55:08
322	ฮกกี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145753	2023-05-16 11:01:47
323	ฮงสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145756	2018-03-06 15:56:24
324	เยาวราชบางปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145757	2025-09-04 11:49:34
325	โง้วฮงหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145758	2009-11-19 14:31:10
326	เยาวราชบางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14576	2016-09-30 11:55:05
327	ฮะฮวดบางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145761	2018-01-09 18:50:26
328	เยาวราชบางบ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145762	2017-09-17 15:54:42
329	แม่ทองดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145763	2017-02-05 17:05:11
330	แม่เงินเย็น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145764	2023-10-31 13:28:07
331	เยาวราชตลาดนิคม	-41601.00	402.350	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145765	2025-10-19 14:43:42
332	เอี่ยมเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145768	2024-06-08 15:43:27
333	เยาวราชบุญศิริ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145769	2022-06-24 13:06:36
334	จิตรลดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14577	2021-11-26 16:41:19
335	มังกรเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145771	2010-05-05 13:36:04
336	วังทองนครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145772	2016-02-21 13:53:00
337	เยาวราชทวีสิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145774	2025-10-26 12:58:07
338	ใช่หลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145775	2009-11-19 14:37:52
339	เยาวราชปู่เจ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145776	2009-11-19 14:38:29
340	เพชรเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145777	2017-04-06 18:29:21
341	โต๊ะกวงท่าแร้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145778	2009-11-19 14:39:25
342	เยาวราชเพชรเกษม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145779	2015-08-19 16:38:11
343	เจริญชัยปัตตานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145781	2019-03-12 13:51:20
345	ทองตากสิน	0.00	3048.800	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145784	2025-10-14 15:30:20
346	หมุยฮะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145786	2025-10-10 15:45:11
347	ตันง่วนไถ่1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145787	2009-11-19 00:00:00
348	แกรนด์ดีเอส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145788	2009-11-19 14:46:52
349	สุวรรณา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145789	2021-01-23 15:53:39
350	สามทหารกบินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14579	2025-09-13 12:21:10
351	ตั้งเฮงล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145791	2009-11-19 14:48:42
352	เฮงสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145792	2014-11-11 13:03:18
353	โง้วชั้งเซ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145793	2009-11-19 14:57:13
354	โซวเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145794	2009-11-19 15:01:02
355	เพชรมณีตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145797	2025-10-15 10:23:04
356	ยิ่นฮงล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145799	2021-09-01 10:30:54
357	ไทยสวัสดิ์ลำปาง	-2003000.00	0.000	0.000	1981.700	0.000	0.000	0.000	2025-11-20 15:38:54.145801	2025-10-25 15:21:48
358	พนิดาดอนเจดีย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145822	2025-03-12 14:05:55
359	ย.โพธาราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145824	2009-11-19 15:16:08
360	ไล้เซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145826	2013-11-12 15:54:54
361	แสงสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145827	2025-03-14 16:10:19
362	หงษ์มังกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145828	2018-09-13 16:51:32
363	แม่วรรณี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145829	2009-11-19 15:18:26
364	ฟู่เฮง	0.00	0.000	0.000	914.650	0.000	0.000	0.000	2025-11-20 15:38:54.14583	2025-10-21 14:23:58
365	หลักเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145832	2025-10-25 15:51:45
366	เหงี่ยมเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145833	2014-01-18 09:23:11
367	เหรียญเงี๊ยบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145834	2017-02-03 16:15:46
368	แหลมทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145837	2010-07-06 13:28:20
369	อัมพวา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145838	2020-04-16 08:48:58
370	อาฟาร์ณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145839	2009-11-19 15:25:24
371	อาฟาร์ตา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14584	2009-11-19 15:26:06
372	อาฟาร์แดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145842	2016-09-02 09:05:39
373	อาฟาร์หงษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145843	2009-11-19 15:26:52
374	อินทรีทอง เชียงใหม่	-16912755.00	0.000	0.000	0.000	0.000	39.250	0.000	2025-11-20 15:38:54.145844	2025-10-26 10:37:38
375	อึ้งเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145845	2017-03-07 17:11:09
376	ฟนักงานหมวยเล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145847	2009-11-19 00:00:00
377	อึ้งเฮี็ยบย่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145848	2025-02-04 15:12:35
378	อุดมรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145849	2009-11-19 15:29:37
379	อุ่นเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14585	2009-11-19 15:30:31
380	ไพลินชัยนาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145852	2015-08-13 17:04:58
381	ไพลินชัยนาท2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145854	2011-10-05 15:09:32
382	เม่งหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145855	2022-02-23 13:02:44
383	ศรีสุวรรณท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145856	2024-05-03 15:08:27
384	ไท้เซ่งฮงบ้านหม้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145857	2025-06-19 10:47:28
385	กรุงเทพเฉวง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145859	2025-09-30 10:40:58
386	กรุงเทพหน้าทอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14586	2025-01-19 13:31:35
387	ทองเซ็นเตอร์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145863	2025-10-17 13:54:38
388	ทวีศิลป์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145864	2025-08-30 11:38:12
389	รุ่งกิจ	0.00	54.300	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145865	2025-09-20 12:53:14
390	โต๊ะกังราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145866	2022-12-28 09:31:23
391	วิไลอรัญ	0.00	0.000	0.000	167.650	0.000	0.000	0.000	2025-11-20 15:38:54.145868	2025-10-26 14:14:19
392	เทพนิมิต2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14587	2024-01-31 12:03:36
393	มังกรปากเกร็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145872	2016-10-29 16:34:37
394	เยาวราชแม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145873	2010-01-13 13:29:08
395	เอกเจริญห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145874	2025-08-07 15:43:57
396	ปน1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145875	2025-09-16 10:02:23
397	สงวนชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145877	2016-09-27 17:00:47
398	เยาวราชสุราษฏร์(อาอี้เล็ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145878	2013-07-10 11:55:14
399	ตุนยก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145879	2025-10-09 16:16:23
400	พี่สาวแม่สมัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14588	2024-03-12 14:37:10
401	ไทยมิตรดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145881	2025-06-13 13:31:29
402	ต.สุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145883	2016-08-28 09:18:47
403	ทองปุ่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145885	2025-10-03 12:28:58
404	ย่งฮงแม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145888	2016-05-03 08:44:48
405	ดีดีรังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14589	2017-05-15 14:05:38
406	ฮั้วเฮงหนองมน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145891	2024-07-17 10:37:51
407	คุณป้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145892	2012-09-13 10:04:36
408	เยาวราชศูนย์การค้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145893	2025-07-29 13:27:33
409	พวงเพชรสวนแตง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145895	2025-09-20 14:33:14
410	สุวรรณรัตน์ไก่แบ้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145896	2015-03-07 15:14:48
411	เคียนฮวดเฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145897	2010-01-21 17:15:11
412	เยาวราชแปด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145898	2015-01-17 15:20:09
414	เจ้าเถิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1459	2009-11-24 17:42:36
415	ดีเอ็ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145901	2022-12-16 12:13:16
416	เซ่งเฮงคลองด่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145904	2025-04-20 10:18:32
417	จี้ฮั้ว1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145906	2025-10-19 13:24:14
418	คุณเตือนแบงค์กรุงเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145908	2010-02-25 10:15:54
419	แม่ทิพย์4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145909	2018-08-08 16:52:27
420	จารุวัฒน์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145911	2019-08-14 12:36:18
421	จารุวัฒน์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145912	2009-11-26 11:23:29
422	จารุวัฒน์3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145913	2009-11-26 11:23:57
423	เพชรทองดีมีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145914	2024-04-03 10:29:52
424	ไท้เซ่งฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145916	2023-08-18 15:13:44
425	คุณน้องmc	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145917	2014-02-11 09:19:54
426	เจริญสิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145918	2013-01-17 00:00:00
427	คุณกิตติ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145919	2023-09-22 11:29:44
428	ดาวทองบางปู2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145921	2010-11-10 09:17:27
429	100%ตลาดลูกแก2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145923	2020-12-03 17:02:55
430	ลิ้มลี่เซ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145924	2013-10-18 13:01:19
431	โกลด์เซ็นเตอร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145925	2016-03-26 10:09:36
432	คุณสมชาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145926	2021-04-20 09:36:24
433	ปน4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145927	2022-06-16 16:34:15
434	จี้ฮั้ว2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145928	2024-04-21 11:41:38
435	ตั้งย่งฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14593	2020-02-22 17:23:43
436	อภิชัยโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145931	2016-09-23 00:00:00
437	คุณแอ๋ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145932	2012-06-11 14:54:05
438	คุณแดงbbl	-4477900.00	0.000	0.000	1981.750	0.000	0.000	0.000	2025-11-20 15:38:54.145933	2025-10-25 10:15:20
439	เลี่ยงฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145934	2024-10-22 15:01:00
440	เยาวราชสุราษฏร์แม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145935	2020-05-31 12:59:27
441	โชคชัย เชียงใหม่	1000.00	0.000	0.000	-21341.600	0.000	0.000	0.000	2025-11-20 15:38:54.145938	2025-10-26 14:12:24
442	เม่งหลีเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145939	2009-12-01 00:00:00
443	ตั้งจินเฮงบ้านโป่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14594	2009-12-09 13:40:01
444	เพชรทองดีมีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145941	2020-05-29 09:34:21
445	คุณเพลินพิศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145943	2013-05-16 10:41:50
446	ธนกิจศรีย่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145944	2012-06-05 14:23:32
447	จินดามีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145945	2020-05-22 09:20:42
448	อุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145946	2009-12-08 14:52:18
449	เยาวราชสี่แยกมีน	-24401.00	210.150	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145947	2025-10-19 14:45:59
450	ออโรร่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145949	2023-02-09 16:10:37
451	เอี่ยมเจ็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145951	2015-09-02 10:35:19
452	คุณหรั่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145952	2010-09-29 13:07:23
453	ห้างทองชม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145955	2012-09-12 13:40:01
454	แสงทองท่ามะกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145956	2024-10-22 10:04:33
455	เยาวราชมีนบุรี	-9446.00	78.300	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145957	2025-10-19 14:59:48
456	ดาพนักงาน	499350.00	0.000	0.000	83.800	0.000	0.000	0.000	2025-11-20 15:38:54.145958	2025-10-26 09:22:57
457	ดารา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145959	2016-10-07 00:00:00
458	สายพิณเตียวเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14596	2022-02-22 10:17:53
459	เยาวราชบางปู99	-90209.00	829.700	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145961	2025-10-19 14:56:04
460	อุษณีA	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145963	2011-05-04 12:09:42
461	เตียเฮงหลีแปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145964	2017-11-16 13:37:01
462	อ้อมใหญ่1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145965	2024-10-26 10:16:01
463	สวนมะลิ1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145966	2023-08-04 11:51:27
464	คุณตาแม่ฟอร์ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145967	2011-01-11 12:24:28
465	เตียเฮงหลีปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14597	2023-05-06 08:57:39
466	ไทยฮั้วปากน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145971	2013-04-27 11:33:02
467	ทองทิพย์ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145972	2025-06-25 15:36:03
468	อุษณีB	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145973	2011-02-22 09:56:32
469	คุณธีรวุฒิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145975	2011-11-26 16:06:03
470	คุณซ้วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145976	2011-10-26 16:02:18
471	ล.รุ่งเรือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145977	2025-08-23 13:40:14
472	ไทยฮั้วปน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145978	2019-06-22 16:08:51
473	คุณวิรัช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14598	2020-12-29 14:14:58
474	กรกชตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145981	2013-01-09 09:52:43
475	คุณศุภกิจ19	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145982	2023-02-21 09:40:28
476	เอสพีเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145983	2025-01-09 16:30:28
477	นำเจริญ1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145989	2021-09-03 11:24:54
478	นำเจริญ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14599	2025-09-04 16:04:26
479	นำเจริญ3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145991	2024-08-27 12:44:58
480	เต็งย่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145993	2022-07-15 16:29:51
481	กาญจนาบางอ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145994	2025-02-02 14:53:14
482	เชียงเส็ง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145996	2018-12-25 17:20:15
483	บุษย์มณี1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145998	2022-06-26 15:25:03
484	บุษย์มณี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145999	2024-06-14 15:50:38
485	วรรณาพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146	2016-09-15 15:34:15
486	ไทยสวัสดิ์เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146001	2025-09-12 15:07:57
487	เอกเซ่งเฮงรังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146004	2024-09-18 14:43:35
488	ลิ้มลี่เซ้งป่าโมกข์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146005	2016-11-27 11:57:11
489	อ้อมใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146007	2013-08-24 13:35:44
490	สังวาลย์สามชุก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146009	2017-09-26 12:30:04
491	ยงกวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14601	2025-10-22 10:58:57
492	มาลัยทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146011	2015-05-15 12:55:18
493	เฮียเกี้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146012	2014-03-01 16:53:00
494	เยาวราชเทพสถิตย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146014	2025-10-11 13:41:42
495	ไช้ง้วน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146015	2009-12-23 14:48:50
496	เยาวราชสะพานใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146016	2024-03-24 09:21:31
497	คุณชูวิทย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146017	2025-10-21 12:04:18
498	กิมเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146018	2025-09-05 15:45:20
499	คุณอัมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146019	2025-09-23 15:55:34
500	พรพจน(เวอรี่กู๊ด)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146021	2014-06-06 14:02:59
501	อุดมพรรณสวนหลวง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146023	2025-07-25 11:11:36
502	ธนกรเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146024	2025-09-03 10:36:08
503	พัฒนาหนองไผ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146026	2025-10-21 15:55:59
504	เกียเฮงเส็งออมสิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146027	2024-11-01 10:11:39
505	เดชอุดมโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146028	2020-10-28 15:03:34
506	เกียเฮงเส็งบางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146029	2025-09-12 14:15:38
507	เกียเฮงเส็งริมคลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14603	2024-10-22 13:15:51
508	พัฒนาสมอทอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146031	2025-04-29 15:47:23
509	แม่คิ้งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146032	2013-10-17 12:00:11
510	ศิริราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146033	2011-10-18 09:57:20
511	เตียฮั้วเฮงแปดริ้ว	5159.30	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146035	2020-05-15 13:06:13
512	คุณหมีเพื่อนปลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146036	2025-10-17 11:19:11
513	คุณปลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146039	2022-03-18 10:24:59
514	แจ๊คเสือมังกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146041	2025-04-05 11:08:43
515	พรเจริญ ตระการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146043	2020-04-16 08:51:28
516	เยาวราชรามอินทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146044	2016-09-30 18:25:09
517	แม่บญเรือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146045	2017-06-06 10:30:18
518	ร้านทัศนีย๋	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146046	2022-04-19 15:01:17
519	หลักเฮง1	4259893.00	0.000	0.000	2241.000	0.000	0.000	0.000	2025-11-20 15:38:54.146047	2025-10-03 10:53:47
520	โชคเจริญตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146048	2015-05-14 16:09:59
521	เตียย่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14605	2010-01-10 00:00:00
522	เอกสุวรรณ3จอมทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146051	2010-01-06 12:09:41
523	สรรชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146052	2013-04-10 09:39:47
524	รุ่งเจริญปน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146053	2010-01-08 11:10:47
525	แม่บุญเรือง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146056	2010-05-10 10:43:27
526	ทองเจริญสุข2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146057	2025-05-24 13:58:40
527	สายอุทัย2เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146058	2025-09-04 13:14:18
528	พร้าวเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14606	2016-01-26 16:15:06
529	ตั้งซินเฮงบ้านโป่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146061	2014-07-05 12:04:34
530	ทองใบพระประแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146062	2022-08-20 09:58:11
531	คุณกานดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146063	2023-02-02 14:56:16
532	สุวรรณศรีระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146064	2023-06-24 14:51:24
533	พรสวรรค์หล่มสัก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146065	2025-10-17 16:43:25
534	เฮียปอ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146067	2010-01-13 10:35:22
535	โอ้วจินหลีเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146068	2010-01-11 17:08:50
536	Same	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146069	2025-10-24 18:24:13
537	เรวดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146072	2020-11-29 14:35:39
538	เยาวราชเอเชีย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146073	2016-10-10 11:19:48
539	พ่อสมชายกบินทร์บุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146074	2025-10-24 17:13:36
540	เดอมอนด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146075	2010-01-14 12:13:58
541	ซุ่นเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146077	2017-08-11 13:33:08
542	เยาวราชฉลองกรุง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146078	2025-08-15 14:45:45
543	ประชาไท2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146079	2010-03-19 13:52:07
544	จิบเซ่งเฮงบางลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14608	2016-07-07 10:16:34
545	ฮั้วชุนเฮงพรานนก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146082	2013-06-07 00:00:00
546	ฮ้วนซินหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146084	2025-09-24 12:32:31
547	ทองทิพย์อำนาจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146085	2023-02-28 10:36:16
548	คุณโก๊ะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146086	2017-06-29 16:07:29
549	*ทวีชัยภูเขียว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146089	2010-01-16 00:00:00
550	หงี่ซุนเส็งร่มเกล้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14609	2025-08-22 13:51:48
551	เพชรไพลิน3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146092	2012-01-11 10:46:19
552	เยาวราชทองคำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146093	2010-06-29 14:36:44
553	รัตนะเขาฉกรรจ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146094	2025-10-19 12:38:15
554	พนักงานหนิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146095	2012-03-27 15:05:13
555	เฮงโต๊ะกัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146096	2025-10-05 12:29:39
556	ทองดีศิลป์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146098	2025-09-16 14:33:27
557	พี่หมวยพนักงาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146099	2016-11-22 14:49:46
558	เยาวราชกรุงเทพชัยนาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1461	2025-10-21 11:52:35
559	แม่อำพัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146101	2016-09-28 12:01:19
560	สง่าน่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146102	2023-03-11 13:09:30
561	ย่งไท้ฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146105	2025-10-26 10:28:45
562	พลอยสยาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146106	2025-10-08 15:19:40
563	อุษณีC	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146107	2011-03-29 14:58:32
564	คุณเต่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146109	2024-10-05 16:12:54
565	เซ่งเฮงล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14611	2023-02-24 15:20:24
566	จารุชัยลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146111	2010-01-23 19:41:22
567	ย่งฮงล้งเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146112	2024-02-22 16:50:11
568	ทองดีขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146114	2015-06-23 10:49:30
569	หงี่ชุนเส็งร่มเกล้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146115	2017-06-06 14:21:56
570	แม่จันทราเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146116	2013-05-21 15:51:27
571	กิ่มฮั้วเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146117	2025-04-29 15:18:28
572	จี้ซินแม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14612	2011-03-17 15:48:57
573	แสงมณีโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146123	2023-03-02 11:03:31
574	ทรัพย์ทวีตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146124	2016-02-27 09:50:27
575	จอมมณีตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146125	2016-03-09 13:45:22
576	โชคชัยศรีสะเกษ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146127	2025-10-08 13:32:02
577	สุขชมตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146129	2016-12-24 09:38:04
578	ธารทองเพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146131	2025-10-24 09:33:55
579	อเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146132	2025-01-11 15:47:38
580	คุงเซ่งเฮงรังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146133	2010-01-26 18:12:40
581	นกแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146135	2018-06-15 15:02:30
582	คุณเพชร(แม่สมัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146136	2010-06-16 12:25:59
583	ห้างทองเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146137	2012-09-18 00:00:00
584	เยาวราชหนองปรือกาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146138	2022-07-16 16:17:02
585	คุณประวิทย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146139	2024-07-17 09:58:28
586	หยงเตียนหาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146142	2025-07-30 10:55:28
587	ศรีสุวรรณเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146144	2022-10-04 15:47:22
588	คุณรัตนาป่าโมกข์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146144	2012-09-02 12:06:25
589	เรวดีบุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146146	2013-07-03 14:09:52
590	ชัยเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146147	2011-10-05 17:33:15
591	คุณไพศาล2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146148	2010-03-26 11:33:13
592	เวรี่กู๊ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14615	2025-05-09 15:39:21
593	ทับเที่ยงตรัง	0.00	0.000	0.000	762.200	0.000	0.000	0.000	2025-11-20 15:38:54.146151	2025-10-22 18:01:13
594	ฮั้วเฮงล้ง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146152	2025-10-01 11:25:09
595	ศรีแสนไว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146153	2014-05-22 15:59:59
596	เอี่ยมฮั่วเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146154	2025-09-15 11:59:22
597	แสงทองตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146156	2018-01-31 16:54:24
598	จินอา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146159	2017-11-05 12:59:46
599	ชัชวาลย์สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14616	2012-07-29 16:23:18
600	อุษณีD	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146161	2011-02-24 15:03:14
601	สุเทพนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146162	2021-01-07 13:38:48
602	ฉัตรทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146164	2020-04-15 11:50:33
603	สุขุมตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146165	2015-10-10 12:47:30
604	ฮั้วสูน	0.00	0.000	0.000	76.200	0.000	0.000	0.000	2025-11-20 15:38:54.146166	2025-10-16 18:22:56
605	ศิริเมืองทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146167	2025-04-18 09:44:10
606	อุดมภัณฑ์แม่จัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146168	2024-06-12 16:46:59
607	ย่งเชียงล้งต้นลำไย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14617	2018-09-12 17:19:01
682	สุขชม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146354	2016-12-10 14:55:10
608	แม่พลอยปากเกล็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146171	2016-09-29 18:49:09
609	เยาวราชคลองรั้งปราจีน	24825.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146173	2018-07-05 09:39:39
610	คุณพจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146176	2016-03-03 14:21:43
611	คุณสมชาย(กุ๊ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146178	2010-02-10 00:00:00
612	คุณขจรเดช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146179	2022-03-10 14:33:15
613	สุนทรีบางปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14618	2025-07-30 14:33:34
614	ราชา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146181	2025-03-25 15:38:17
615	ณัฎฐ์ทวีอุดรธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146182	2016-01-10 10:00:42
616	ทองประดิษฐ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146184	2022-11-09 17:17:02
617	ชัชวาลย์สระแก้ว	0.00	40.700	0.000	609.750	0.000	0.000	0.000	2025-11-20 15:38:54.146185	2025-10-01 15:08:19
618	เยาวราชสหพัฒน์ว้ดไทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146186	2016-08-26 10:32:05
619	น้ำหนึ่งชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146187	2025-10-22 15:59:20
620	เลิศสุวรรณ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146188	2011-11-27 15:47:20
621	นพคุณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14619	2017-11-26 17:06:18
622	จารุวัฒน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146193	2015-08-04 08:54:28
623	ประสพชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146194	2020-02-23 09:13:01
624	รุ่งโรจน์ลาดหลุมแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146195	2024-12-17 09:37:46
625	คุณชูศักดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146196	2010-02-09 13:28:10
626	ทองเจ๊ยู้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146197	2018-11-21 17:52:56
627	เยาวราชบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146198	2024-10-25 12:13:17
628	ทองมงคลปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1462	2015-02-03 13:30:41
629	สวิสแม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146201	2024-01-19 11:15:41
630	อุษณีE	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146202	2011-03-29 14:58:48
631	คุณตุ้ย14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146203	2022-03-08 13:27:43
632	เยาวราชเขาฉกรรจ์	0.00	346.050	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146204	2025-10-19 12:20:24
633	สิณีเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146206	2010-02-11 13:53:37
634	มังกร9เจริญผล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146208	2013-03-26 00:00:00
635	คุณสมใจ14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146209	2013-09-18 17:04:28
636	เยาวรชฉลองกรุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14621	2010-02-17 15:12:36
637	ชัยเจริญปากคลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146212	2011-10-11 11:25:45
638	แม่ยินดีปร2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146213	2015-10-29 16:12:51
639	หงี่ซุนเส็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146214	2014-01-08 13:52:50
640	เยาวราชลี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146215	2016-01-23 10:35:01
641	จันทร์สม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146218	2025-10-07 11:24:31
642	ทองกรุงเทพศรีสะเกษ	-2098600.00	0.000	0.000	1829.300	0.000	0.000	0.000	2025-11-20 15:38:54.14622	2025-10-16 13:39:13
643	มีมีจันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146221	2025-09-09 15:52:54
644	แสงเจริญลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146222	2023-11-19 13:02:25
645	ลัคกี้เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146224	2023-02-17 16:02:34
646	เลิฟลี่เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146226	2020-08-09 13:05:32
647	เลดี้เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146227	2021-03-07 15:52:54
648	สามวิภา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146229	2025-09-26 15:19:36
649	เจียระสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14623	2025-01-05 14:21:05
650	เม่งหลี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146231	2013-07-23 13:25:51
651	อุเทนอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146232	2024-05-30 10:50:42
652	เยาวราชสินทวี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146233	2018-01-16 16:07:25
653	เฮงรุ่งเรือง พรานนก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146235	2025-10-02 11:57:24
654	โตเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146236	2013-07-07 11:41:11
655	พ่อสมชายกบินทร์บุรี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146237	2010-02-26 16:26:27
656	หงี่ชุนเส็งราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146238	2022-03-11 13:58:33
657	คุณทัศนีย์mmp	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146241	2020-04-03 11:43:59
658	ทองแท้เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146243	2010-06-18 13:43:01
659	มังกร9แม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146245	2012-01-04 00:00:00
660	*ฮั้งจิว2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146324	2010-03-15 00:00:00
661	*ฮั้งจิว3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146325	2010-02-28 00:00:00
662	วังทอง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146326	2013-05-08 15:04:23
663	เอ็งฮั้วสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146327	2025-10-19 13:03:35
664	คุณนิยดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146328	2020-07-22 14:58:34
665	หงีซุนเส็ง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146329	2025-02-01 12:07:10
666	พันทวีโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146331	2019-12-15 11:56:22
667	แสงทองใบพระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146332	2025-10-15 16:01:29
668	ทองอุไร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146333	2025-03-15 11:51:26
669	ผูกมิตรบางเลน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146334	2012-05-12 18:40:16
670	ทองใบเยาวราชบางวัว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146338	2024-06-08 16:23:38
671	วังทองชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146339	2022-04-24 08:49:20
672	ชัยธานีลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146341	2024-10-29 12:39:51
673	ฟู่เฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146343	2016-09-29 16:56:03
674	จิบเซ่งเฮงเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146344	2018-09-28 13:59:34
675	สง่าสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146345	2010-03-09 17:39:11
676	ยิ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146346	2023-05-06 08:58:10
677	วัขรินทร์นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146347	2011-01-29 13:09:33
678	เยาวราชไพบูลย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146349	2016-05-26 00:00:00
679	เยาวราชกิ่งแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14635	2025-07-16 11:17:24
680	มีมีจันทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146351	2014-10-05 13:59:13
681	คุณอู๊ดปลืก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146352	2012-09-25 12:37:22
683	นพคุณปากช่อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146355	2012-12-23 12:52:20
684	กิมเล้งหงษ์เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146357	2019-07-10 15:44:52
685	เฮียนึกนวนคร2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146358	2014-08-28 09:43:39
686	กมลรัตน์เพื่อนสันฤทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146359	2021-01-12 14:14:44
687	จองกาญจนานครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14636	2017-02-28 15:38:42
688	กรุงเทพหาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146361	2010-05-13 10:36:03
689	เอกเซ่งเฮงกรุงเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146362	2011-03-03 15:34:00
690	แม่ทองใบเซ็นทรัลบางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146363	2025-07-04 15:14:56
691	วรรณพรตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146364	2014-10-07 13:39:59
692	อัญชลีเพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146365	2025-10-04 12:07:03
693	สกุลรักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146366	2010-04-26 16:16:39
694	วังทอง2พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146369	2022-03-15 14:56:08
695	คุณตระการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14637	2011-06-04 13:20:00
696	อากู๋(วรรณาเธียร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146371	2025-05-17 11:59:35
697	อุษณีG	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146373	2010-04-08 11:19:53
698	เยาวราชอุดมสุข(ช่างโหง่ยฮั้ว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146374	2015-12-15 00:00:00
699	เพชรพลอยแฟคตอรี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146375	2018-09-08 17:36:25
700	ฮ้างหว่าเต้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146376	2025-10-24 12:10:46
701	แม่ยินดีแปดริ้ว(ปลีกแป็ด)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146377	2010-04-10 10:41:13
702	ทวีเยาวราชอุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146378	2024-07-02 09:59:37
703	ดำรงชัยอิมพีเรียล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14638	2016-07-06 10:58:22
704	พงษ์ทองดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146382	2017-02-08 17:32:39
705	ชัชวาลย์จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146383	2025-09-26 14:00:05
706	สหพัฒน์บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146386	2020-02-06 16:10:46
707	สิทธิพงษ์ศรีสะเกษ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146387	2010-03-30 18:31:23
708	เบ๊เฮงฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146388	2020-08-13 12:17:15
709	อ้อยทองดีสาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146389	2022-09-27 16:33:49
710	เพชรมณีปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14639	2013-05-25 00:00:00
711	กอล์ฟ(เพื่อนหมี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146391	2012-07-24 11:18:36
712	คิ้ม(เพื่อนหมี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146392	2010-04-09 09:01:32
713	ตุ้ม(เพื่อนหมี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146393	2010-04-09 11:04:24
714	แม่เจง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146395	2019-10-08 15:34:05
715	กรุงเทพห้วยไคร้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146396	2023-09-11 15:45:01
716	พงษ์ทองดี5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146397	2010-04-07 18:11:18
717	แม่ทองใบซีคอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146398	2022-10-21 15:41:20
718	คุณอ้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146403	2012-01-28 11:43:15
719	สิทธิโชค2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146404	2010-09-22 00:00:00
720	เฉลิมพร3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146405	2018-11-13 16:25:08
721	สังวาลย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146406	2010-04-09 10:27:24
722	เยาวราชประตูเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146408	2019-06-11 11:32:21
723	เพชรแก้วภูเก็ต	0.00	0.000	0.000	1524.400	0.000	0.000	0.000	2025-11-20 15:38:54.146409	2025-06-21 14:19:44
724	ศิริรุ่งแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14641	2020-08-04 09:01:44
725	เยาวราชกรอบพระ	-55053.00	466.950	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146411	2025-10-19 14:43:16
726	แดงน้อยท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146413	2025-07-05 11:43:10
727	เจริญสุขอุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146414	2023-03-21 16:14:04
728	สามวิภากระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146416	2023-11-03 13:49:40
729	มังกรทองหาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146417	2022-03-27 14:02:39
730	เยาวราชลาดหลุมแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146418	2023-11-08 12:47:58
731	ย่งล้งสุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14642	2013-12-24 11:07:48
732	ยิ่นฮงล้ง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146422	2011-04-24 17:43:39
733	ดีดีสาว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146423	2021-12-18 15:54:39
734	พลอยเพชรรัตน์นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146424	2016-07-22 10:01:02
735	สินทวีบางมด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146425	2024-10-22 10:59:42
736	โต๊ะกังเฮงกี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146428	2022-06-23 16:00:41
737	สุวรรณศรีระยอง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146429	2016-05-15 11:07:46
738	ทับทิม24กะรัต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14643	2021-03-23 11:51:58
739	นิดาท่าเรือ	0.00	0.000	0.000	304.900	0.000	0.000	0.000	2025-11-20 15:38:54.146431	2025-10-24 17:02:58
740	มังกรเยาวราชดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146433	2020-10-07 13:58:53
741	จองกาญจนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146434	2016-03-05 16:17:40
742	เฮงเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146435	2023-12-22 16:50:20
743	รุ่งเรืองหนองไผ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146439	2017-03-16 13:25:39
744	โต๊ะกวงท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14644	2021-12-03 15:43:02
745	อิกล้ง1ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146441	2020-01-15 16:44:53
746	อิกล้ง2ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146442	2017-12-21 14:12:11
747	สหไพบูลย์ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146443	2018-09-12 17:25:33
748	เพชรดำรงค์2ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146444	2021-12-21 17:20:24
749	แม่ทองบาง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146445	2022-03-01 16:04:13
750	เยาวราขเซ่งหงษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146446	2017-08-18 12:11:48
751	เอกภัณฑ์เยาวราชเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146448	2025-01-09 15:18:46
752	เอกภัณฑ์พร้าวเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146449	2025-10-24 10:19:56
753	แสงทองแม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14645	2012-09-20 16:48:56
754	กาญจนาบางเลน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146451	2024-03-22 15:12:05
755	ย่งฮวด	0.00	2668.400	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146453	2025-07-19 09:40:47
756	เพชรอรุณพิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146455	2021-07-02 14:12:36
757	พลอยศักดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146456	2024-02-27 16:24:21
758	เอกเจริญปากช่อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146457	2024-04-23 14:37:51
759	เยาวราชสุราษฏร์	0.00	0.000	0.000	304.900	0.000	0.000	0.000	2025-11-20 15:38:54.146458	2025-10-09 11:07:13
760	แม่ทองบาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146459	2013-06-21 10:16:15
761	สุวรรณพัฒนา3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14646	2018-06-29 15:29:56
762	ดีแสงดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146461	2025-10-24 12:10:12
763	โต๊ะกังสมจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146463	2022-12-22 10:26:52
764	แม่ฮั้งนี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146464	2014-01-21 10:20:43
765	100%พาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146465	2022-03-08 11:25:45
766	สมานมิตรโกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146466	2024-03-23 09:53:58
767	แม่ยุพิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146469	2020-02-15 15:05:59
768	เซ่งเฮงคลองด่าน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146472	2010-06-16 09:46:43
769	ทองแท้อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146473	2024-03-13 14:59:16
770	มุกดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146475	2021-04-10 17:03:01
771	พีระยุทธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146476	2014-08-07 11:57:20
772	ทองดีโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146477	2016-05-29 00:00:00
773	มหางาม1(พิมพร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146478	2016-09-22 10:37:42
774	พนักงานปุ๊ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14648	2025-10-01 11:08:48
775	ย่งไท้เชียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146481	2016-10-02 15:10:34
776	ลำปางบริบูรณ์	0.00	270.650	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146482	2025-09-12 11:50:10
777	ลิ้มง่วนเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146484	2020-06-06 10:54:13
778	เยาวราชภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146485	2024-04-28 14:15:51
779	ดีจริงหนองแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146487	2019-11-17 15:02:03
780	มังกรเยาวราชติวานนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146488	2022-08-10 16:57:26
781	ช่างอู๋	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14649	2025-09-13 12:46:24
782	ยั่งฮับเต็งพ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146491	2019-03-13 16:23:18
783	ดาราอาอี็	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146492	2010-06-30 17:14:46
784	ตั้งง่วนเชียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146493	2022-05-10 15:32:27
785	ช่างผึ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146494	2016-09-24 15:00:53
786	ทองมงคล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146495	2014-08-19 12:58:41
787	ศรีแหลมทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146497	2020-11-25 13:54:38
788	คุณวิชัย(เอกทองชุมแพ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146498	2012-03-01 11:02:03
789	เยาวราชเซ่งหงษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146499	2014-01-07 13:54:13
790	เล็ก-นิด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1465	2022-10-04 13:50:17
791	อุษณีI	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146503	2011-02-24 15:00:05
792	อุษณีH	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146504	2011-02-22 09:57:12
793	อุษณีJ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146504	2011-02-24 15:02:23
794	สุขเจริญชัยราชวัตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146505	2018-02-02 16:42:20
795	นวทองคำฟิวเจอร์รังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146507	2012-02-03 16:55:16
796	ไทยยินแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146508	2022-06-23 11:17:20
797	ไทยย่งเต็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146509	2024-07-17 16:19:58
798	พรพรรณบางเลน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14651	2010-07-10 12:21:22
799	แม่กิมเตียง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146512	2019-08-31 10:26:42
800	เอกเซ่งเฮง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146514	2025-03-05 10:45:59
801	รุ่งนภาทองดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146515	2014-06-24 12:08:04
802	เยาวราชกิ่งแก้ว1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146516	2010-09-07 09:33:18
803	เยาวราช9ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146518	2024-10-05 13:36:22
804	เฮียกวงนวรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14652	2013-05-07 16:28:34
805	ซือกิมเฮงแม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146521	2025-06-19 13:23:16
806	เอกภัณฑ์ พร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146522	2025-02-04 17:24:14
807	แม่ยินดีลำนารายณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146523	2014-09-11 11:37:03
808	เล่งเซ่งเฮงแพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146524	2016-09-28 12:21:07
809	เฉลิมโชคเลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146525	2024-02-17 21:15:33
810	เล่งเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146526	2016-02-19 08:42:27
811	เยาวราชกันทรารมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146528	2015-12-23 10:17:18
812	คุณเซม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146529	2010-07-24 16:58:45
813	แม่กิมเตียง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14653	2010-07-24 17:27:41
814	ช โชคดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146531	2025-06-29 14:09:39
815	ช่างเจียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146534	2016-09-30 18:17:23
816	คุณสมจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146535	2011-02-17 11:28:38
817	เยาวราชคลองรั้ง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146536	2010-09-24 18:13:45
818	คุณมาลี14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146538	2021-07-20 13:08:43
819	อุษณีZ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146539	2010-08-19 10:31:18
820	คุณนพวุธ22	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14654	2010-12-29 16:23:04
821	อุดมพรรณบางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146542	2025-10-07 09:17:28
822	เพชรรัตน์ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146543	2025-01-19 14:54:27
823	อุษณีK	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146544	2010-08-19 10:31:02
824	มังกรทองแม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146546	2021-02-09 17:14:34
825	นันทชัยเชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146547	2010-08-06 10:19:33
826	โชคชัยไทยประกัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146548	2023-03-11 09:23:20
827	ทองใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146552	2013-11-16 17:29:21
828	ฮ้งเซ่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146553	2010-08-10 16:17:37
829	ทองแท้มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146554	2013-06-22 13:12:42
830	โกลด์เซ็นเตอร์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146555	2010-08-11 09:32:48
831	ทองทวีทรัพย์อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146558	2011-04-19 16:24:11
832	ไฉ่เฮงฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146559	2016-01-14 15:43:30
833	ไช้เฮงฮวดเชียงแสน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14656	2025-10-04 13:09:13
834	ธงชัยอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146561	2025-06-17 09:12:23
835	ดีดีเก้า สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146563	2025-06-17 10:25:13
836	แม่กิมเตียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146564	2016-03-09 08:41:38
837	ภาสวรรณบางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146565	2010-08-21 18:14:47
838	ภาสวรรณบางเลน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146566	2013-10-26 13:11:50
839	แพรทองอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146569	2025-06-29 09:38:16
840	เบ๊ทองฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14657	2014-08-08 15:52:12
841	ช้างดาว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146571	2023-04-29 09:06:02
842	คุณหย่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146572	2010-08-31 16:31:39
843	นิดาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146573	2011-11-26 12:33:17
844	มหาลาภร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146575	2018-04-26 13:28:07
845	มังกรล่ำซำบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146576	2025-08-28 15:28:30
846	โชคดีบางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146577	2011-03-05 10:11:36
847	ซือกิมเฮงไชยปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146578	2017-01-26 09:09:07
848	เต็กเซ้งฮวดอุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146579	2013-08-18 00:00:00
849	มหาชัยอุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14658	2025-10-11 13:49:06
850	แสงทอง3แม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146582	2016-08-31 16:44:23
851	ทรัพย์ทวี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146584	2021-03-19 17:07:58
852	บู๊เซ่งเฮงลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146585	2025-08-08 15:38:25
853	เพชรรัตน์ขอนแก่น2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146586	2016-09-18 13:06:05
854	เอี๊ยะง้วน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146587	2010-09-07 14:50:06
855	ไพฑูรย์เพชรทองดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146588	2025-05-24 13:59:02
856	พรภัณฑ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14659	2012-03-27 09:28:30
857	พันธ์ประเสริฐ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146591	2025-02-07 10:12:22
858	อี้เซ่งเฮงบางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146592	2010-09-13 16:56:25
859	เยาวราชตระการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146593	2024-06-28 09:14:44
860	ซือกิมเฮงฝาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146594	2025-08-29 10:27:42
861	สหพัฒน์วัดไทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146595	2020-05-22 10:52:53
862	อัศวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146597	2011-02-15 17:21:42
863	ไพศาล2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1466	2025-06-05 09:43:41
864	แม่สุภาลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146601	2017-06-08 16:06:52
865	ทองใบสวนพลู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146603	2019-11-15 15:25:14
866	แสงเจริญบางปะกอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146604	2016-01-12 17:02:29
867	ทองสยามระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146605	2023-10-24 13:44:02
868	เยาวราชจอมบึง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146606	2011-04-23 09:41:27
869	ง้วนเซ่งเฮงฟิวเจอร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146607	2013-11-22 13:50:32
870	เจริญไทยอุตรดิตถ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146608	2025-10-25 11:49:59
871	เยาวราชกรุงเทพบุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146609	2020-03-13 14:28:35
872	สุขเจริญชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14661	2017-01-19 09:41:08
873	จงเจริญแพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146612	2010-09-24 11:45:49
874	เยาวราช304	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146613	2014-05-31 00:00:00
875	ยิ่งเฮงเส็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146614	2025-10-18 15:30:00
876	ตั้งเส่งฮะเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146616	2024-11-28 15:04:13
877	คุณนายเปี๊ยก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146617	2012-07-07 14:00:06
878	ลิ้มซำเส็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146618	2013-03-27 15:19:08
879	เบ๊ทองฮวดปากคลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146619	2016-12-04 14:41:07
880	แสงรวีทุ่งสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14662	2025-09-16 15:45:55
881	คุณนวรัตน์(วิไลอรัญ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146621	2010-10-05 09:09:52
882	เยาวราชกรุงเทพไทยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146623	2020-02-01 12:06:52
883	เยาวราชอำเภอ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146625	2015-06-20 14:10:46
884	เยาวราช2แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146626	2010-10-02 11:53:02
885	อุดมพรรณแม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146627	2023-01-06 10:37:48
886	เยาวราชตลาดบ้านดู่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146628	2012-04-29 13:56:55
887	รวีวรรณกำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146629	2020-08-04 09:00:19
888	เยาวราชกรุงเทพไฮเทค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146632	2025-08-06 10:02:58
889	กำปั่นทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146633	2025-10-03 16:06:16
890	เอก2(สุบิน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146634	2011-01-11 14:55:02
891	เลี่ยงเซ้งตากใบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146635	2015-04-25 16:52:52
892	ยั่งฮับเต็งหาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146636	2021-11-19 12:34:04
893	ยั่งฮับเต็งแอนด์จิวเวลรี่BigCปัตตานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146637	2022-07-14 16:12:44
894	เยาวราชปากชม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146639	2014-10-21 16:14:34
895	เยาวราชกรุงเทพท่าวังผา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146641	2025-10-18 14:33:56
896	ศ.วิเชียร(เชึยงราย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146643	2025-10-07 12:33:36
897	รัตนา(อ้อมใหญ่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146644	2017-03-11 14:25:03
898	เยาวราชกบินทร์บุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146645	2010-12-11 13:46:42
899	เยาวราชหล่มเก่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146646	2010-10-13 16:00:54
900	กิมเล่งเฮงโต๊ะกัง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146649	2015-03-07 10:22:21
901	กิมเล่งเฮง2โต๊ะกัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14665	2015-12-19 11:22:33
902	คุณอุษณี(ซ้อณี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146651	2025-10-22 18:24:39
903	กิ๋มมลBBL	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146652	2013-10-01 11:30:13
904	เจี่ยจิวเฮงนครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146654	2024-12-13 16:11:49
905	มณีนพเก้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146655	2016-09-24 15:45:43
906	เจริญรัตน์ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146656	2024-08-04 13:28:11
907	เจริญศิลป์ท่ายาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146657	2011-02-27 12:50:31
908	ศรีเจริญศรีประจันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146658	2013-09-29 11:06:09
909	เฉลิมโชค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146659	2022-11-27 10:20:40
910	โชกุน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14666	2015-03-05 12:23:23
911	จันทร์เกษมดิโอลด์สยาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146661	2023-10-07 14:39:24
912	เยาวราชชุมแพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146665	2010-11-05 14:26:07
913	เยาวราชพระยืน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146666	2025-02-27 13:14:54
914	ศรีฟ้าดีดาวคนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146667	2020-03-12 16:24:11
915	ศรีฟ้าดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146668	2012-06-19 10:13:49
916	ชินสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146669	2025-09-10 13:06:16
917	ไทยวานิช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14667	2022-06-14 13:32:30
918	เยาวราชตลาดนิคม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146671	2010-11-17 16:44:31
919	เอ็งรักฮึ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146672	2013-03-16 17:05:00
920	เฮงหลีโพธิ์สามต้น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146673	2021-09-22 11:42:46
921	เลิศมณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146675	2025-09-28 13:26:06
922	คุณเอี่ยง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146676	2010-11-10 12:12:33
923	ยินดีชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146677	2017-07-22 15:08:35
924	หย่งฮะเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146679	2017-02-23 15:44:39
925	ทองใบ1นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14668	2025-10-19 15:03:51
926	เมืองทองยโสธร	1000.00	0.000	0.000	762.200	0.000	0.000	0.000	2025-11-20 15:38:54.146683	2025-10-18 09:55:40
927	ครูอัสสัม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146684	2011-04-09 09:22:27
928	99วารินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146685	2016-12-02 15:09:22
929	สุวรรณกาญจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146686	2025-10-24 15:38:10
930	เอก2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146687	2012-11-03 14:00:17
931	คุณแจ๋ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146689	2016-11-10 08:53:08
932	วังทองยโสธร	0.00	76.200	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14669	2025-10-18 13:25:47
933	นายซุ่นแถ่นแก่งคอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146691	2025-10-05 15:12:53
934	คุณสุรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146692	2016-03-24 12:36:31
935	พนักงานหมวยใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146693	2012-01-31 15:51:12
936	เพชรทองดีท่าน้ำนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146696	2025-03-16 10:54:16
937	เยาวราช99โลตัส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146697	2016-09-29 10:29:41
938	เยาวราช99เชียงคาน	0.00	3.150	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146698	2016-06-23 10:29:28
939	คุณจวง(ดาวทองมหาชัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146699	2012-09-19 09:21:39
940	สุวรรณภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1467	2025-08-13 15:57:33
941	สวนหลวง	288.00	20.800	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146701	2016-09-23 17:26:07
942	บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146703	2023-02-25 15:56:20
943	เอราวัณเยาวราชบางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146704	2017-09-30 14:52:24
944	เยาวราชหัวหมาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146705	2015-03-14 12:49:12
945	แม่ทองพลูออริจินอล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146706	2024-06-06 15:12:42
946	ไทยหยูล้งโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146707	2018-03-08 14:19:51
947	เฮงหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146709	2024-10-16 15:28:01
948	เยาวราชปูทอง5	-17573.00	148.500	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146711	2025-10-19 14:54:02
949	โต๊ะกังลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146712	2012-03-25 12:18:56
950	สหรัตน์เยาวราชพระราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146713	2025-10-03 09:28:03
951	คุณซ้อเลี่ยงหน่ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146715	2024-03-21 15:36:41
952	ทองปัทมาชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146716	2010-11-19 17:48:00
953	รุ่งโรจน์หนองหญ้าไทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146717	2018-12-23 17:10:32
954	เนรมิตสัตหีบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146718	2013-07-03 12:23:02
955	แม่คิ้มเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146719	2025-09-25 10:43:44
956	แม่ทองบาง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14672	2016-10-27 14:59:32
957	วิไลอรัญ(คุณเอ๋)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146721	2010-12-04 10:37:09
958	เยาวราชลพบุรี(เฮียอ้วน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146724	2012-02-22 13:24:17
959	ชั้นหนึ่งระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146725	2025-09-20 14:18:38
960	กุลศรีสุวรรณ(นิมมานเหมินทร์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14673	2022-09-28 15:52:36
961	คุณตู้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146731	2013-06-25 12:56:46
962	ช่างชายน์นิ่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146732	2012-01-12 14:34:40
963	เพชรทอมสัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146733	2019-06-19 17:23:39
964	100%พาน(สุวรรณ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146734	2012-03-24 13:15:57
965	เมืองทองสกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146735	2016-09-28 14:29:49
966	ทองบริสุทธิ์พระประแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146736	2015-07-04 16:36:10
967	เยาวราช7ฉลองกรุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146737	2025-08-30 14:14:22
968	ทองพระอินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146739	2025-04-03 12:48:25
969	เยาวราช9ลาดกะบัง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14674	2020-08-07 08:57:18
970	สินไพศาล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146741	2011-01-22 11:32:30
971	อินโดบางปะอิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146743	2023-09-13 13:23:03
972	เมืองทอง1ยโสธร	0.00	0.000	0.000	304.900	0.000	0.000	0.000	2025-11-20 15:38:54.146745	2025-10-24 16:29:29
973	เพชรประเสริฐ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146746	2025-09-05 10:44:39
974	วังม่วงสระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146748	2024-04-06 13:33:10
975	สมเดชชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146749	2010-12-04 17:12:44
976	ชั้นหนึ่งระยอง(สาขา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14675	2024-03-13 16:34:29
977	ยิ่งทวีน่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146751	2024-03-15 13:53:55
978	วังทองบางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146752	2011-02-16 16:59:38
979	สุขแก้วชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146753	2022-07-07 16:13:44
980	เยาวราชมีจงมี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146754	2016-07-15 15:48:45
981	เยาวราช99เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146756	2017-01-21 20:13:42
982	แม่จันทราเชียงใหม่1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146757	2011-02-23 09:38:55
983	หย่งฮะล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146758	2025-10-21 13:49:17
984	แม่หงษ์บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14676	2012-11-17 13:13:31
985	เจริญรัตน์หนองตม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146762	2025-06-26 15:44:43
986	เฮียบหยู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146763	2025-06-22 13:57:25
987	24กะรัต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146764	2014-07-02 09:05:07
988	ทองทิพย์ภูเก็ต2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146765	2017-03-21 14:21:22
989	ทองคำเยาวราชพระราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146766	2016-09-28 15:08:19
990	คุณชูเกียรติ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146769	2011-09-15 11:26:59
991	แม่ไน้5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14677	2025-09-24 12:47:28
992	ทองสุกพัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146771	2015-08-21 09:03:57
993	ไทยหยูล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146772	2012-12-18 14:02:58
994	ยู่หลงสาขา	-5851639.00	0.000	0.000	369.650	0.000	0.000	0.000	2025-11-20 15:38:54.146774	2025-08-22 10:41:56
995	นวทองคำ(นวนคร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146775	2010-12-17 12:55:01
996	แม่ทองพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146777	2010-12-22 16:43:30
997	ไทยมิตรอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14678	2022-01-30 14:25:56
998	ทวีทรัพย์บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146781	2025-09-27 10:20:38
999	100%พาน(ศิริณี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146782	2013-04-28 12:18:36
1000	กิมเซ่งเฮงสระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146783	2016-10-10 10:10:03
1001	คุณแขกคุณหนิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146785	2024-10-04 14:33:22
1002	ชัยเจริญบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146786	2017-06-07 16:46:32
1003	พูนฑริก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146787	2011-02-01 10:02:39
1004	เยาวราช7โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146788	2012-05-12 18:39:56
1005	มังกรแพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14679	2024-03-12 16:43:50
1006	ทองพูนอุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146791	2013-04-25 19:09:24
1007	เยาวราชอิมพีเรียลสำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146792	2022-03-04 13:12:34
1008	ชัยเจริญ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146795	2023-10-28 11:59:49
1009	สุวรรณหงษ์พระประแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146796	2024-10-17 10:50:32
1010	ทองทิพย์อำนาจเจริญ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146797	2021-05-18 09:24:24
1011	เยาวราชบุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146799	2022-03-04 13:10:14
1012	ศิริวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1468	2023-02-25 15:58:50
1013	จินดาเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146801	2025-09-26 13:24:52
1014	เยาวราชท่าประชุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146826	2014-12-16 16:13:15
1015	แสงสุวรรณชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146828	2023-11-21 16:15:18
1016	ศรีสุพรรณแม่สอด(จตุพล)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14683	2016-10-18 11:25:17
1017	เยาวราช๙โลตัสศาลายา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146832	2016-08-18 08:51:33
1018	หงี่ชุ่นเส็งประเวศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146834	2016-02-11 13:54:20
1019	เหรียญทองแม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146836	2024-07-23 09:49:52
1020	แม่ยินดีปร(อุทัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146837	2011-02-22 11:28:31
1021	ทองสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146842	2018-03-01 16:29:13
1022	แม่หงส์บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146845	2018-08-29 18:35:36
1023	แม่หงษ์3บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146846	2025-03-11 15:24:25
1024	คุณผึ้งmmp(นพพร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146847	2011-09-06 10:03:59
1025	เคหะทองคำ1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146849	2014-05-07 10:26:21
1026	คุณทัศนียmmp(น้อง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14685	2011-04-01 00:00:00
1027	แสงระวีทุ่งสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146851	2024-09-21 09:58:33
1028	เคหะทองคำ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146852	2013-01-09 14:17:21
1029	ใต้ฟ้าอู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146854	2019-06-25 15:24:10
1030	ชัชวาลย์จัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146855	2018-06-02 12:41:49
1031	ทองน้ำหนักเต็มเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146856	2025-06-10 10:06:11
1032	มาตรฐาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146857	2013-01-19 12:09:02
1033	เก้ามณีท่าเรืออยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146869	2024-12-06 15:41:16
1034	วีระชัยอู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146872	2024-09-18 13:56:01
1035	เจริญสักหล่มสัก(เพชรบูรณ์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146873	2011-03-06 11:16:29
1036	เฮงเฮงนวนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146874	2012-05-20 12:26:52
1037	อุษณีF	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146875	2011-02-25 15:28:54
1038	ไทยมิตร2อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146877	2022-04-19 15:24:44
1039	PG	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146878	2012-01-10 13:16:55
1040	ทองประพันธ์(เพื่อน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146879	2012-06-02 13:08:44
1041	ทองสยามชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14688	2023-03-15 14:17:34
1042	บุญมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146881	2025-10-21 13:00:19
1043	เยาวราช99บางขุนเทียน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146882	2013-10-25 15:50:37
1044	กิจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146883	2016-09-30 17:52:29
1045	ศรีโต๊ะกังดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146886	2025-07-25 14:49:18
1046	เพชรทองเยาวราชอุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146888	2013-12-17 14:17:42
1047	พรเจริญอุบล	-662773.68	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146889	2025-10-24 16:56:13
1048	ดำรงชัยอิม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14689	2013-09-03 11:38:41
1049	เยาวราชตากฟ้านครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146891	2024-05-19 13:09:07
1050	เพชรทองเยาวราชนครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146893	2025-10-24 15:20:45
1051	ดีดีแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146894	2011-05-26 00:00:00
1052	วังทองอำเภอพาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146895	2025-10-08 11:36:11
1053	พานทองโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146898	2011-04-30 18:07:36
1054	อารยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146899	2014-11-15 14:37:59
1055	เอราวัณพิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146901	2023-10-27 10:41:18
1056	เบลล์ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146902	2020-12-29 16:40:36
1057	ช่างธรธวัช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146905	2014-07-12 12:32:41
1058	เล็กนิด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146906	2013-03-26 17:44:10
1059	คุณทัยแท่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146907	2011-08-25 00:00:00
1060	มีสวัสดิ์บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146908	2018-10-19 11:28:45
1061	ทวีสินแม่สรวย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14691	2020-09-01 12:44:23
1062	เพชรอรุณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146911	2018-09-08 18:03:28
1063	ภาสวรรณ3บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146912	2011-03-13 14:16:13
1064	เยาวราชตราย่าโมโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146913	2011-01-23 17:30:06
1065	เยาวราชสวิสเลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146915	2025-05-29 15:40:46
1066	อาหลักอี็	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146916	2012-02-16 17:13:01
1067	คุณอุไร(ญาติเปิ้ล)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146917	2013-02-13 09:36:53
1068	คุณพวงเพชร(ญาติเปิ้ล)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146918	2011-02-09 10:05:25
1069	เยาวราชกระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146921	2022-08-14 10:01:25
1070	แม่ทองใบงามวงค์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146921	2015-10-20 13:09:10
1071	โต๊ะกังรามอินทรากม.7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146923	2025-09-09 13:58:38
1072	เทพพิทักษ์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146924	2025-10-22 10:57:32
1073	เยาวราชกิจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146925	2022-06-16 10:14:54
1074	คุณวิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146926	2025-10-24 15:25:19
1075	โต๊ะกังประชาอุทิศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146928	2025-09-25 14:19:53
1076	เยาวราชอุดมเดช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146929	2022-12-22 17:33:24
1077	ทวีโชคสะพาน4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14693	2025-09-13 13:15:08
1078	อุษณีM	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146931	2011-02-22 09:55:45
1079	ย่งฟ้าวังน้ำเปรี้ยว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146933	2024-07-25 13:58:20
1080	อุษณีL	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146934	2011-02-22 09:54:46
1081	สุขขุมคลองใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146937	2025-07-24 14:26:44
1082	ตั้งเซียมเฮง1พิจิตร	-471.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146938	2025-05-03 15:07:04
1083	นครพรรณ(ชม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146941	2022-04-09 13:57:02
1084	บุญฑริก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146942	2015-12-23 12:34:16
1085	หลักเฮง(ยุทธ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146945	2011-08-03 11:24:28
1086	สีฟ้า1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146946	2025-10-25 15:01:48
1087	ชมพู7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146947	2021-05-05 15:42:48
1088	อ้อมใหญ่2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146948	2024-10-26 10:36:48
1089	ฮั้วหงษ์เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14695	2016-10-11 10:08:02
1090	โต๊ะกังงามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146951	2024-06-21 16:02:42
1091	แม่ทองใบแฟชั่นไอร์แลนด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146952	2016-09-29 13:42:15
1092	ดีจริงพยัคฆ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146953	2025-09-09 11:36:19
1093	หงษ์ทองเยาวราช ฝาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146956	2024-02-02 14:44:25
1094	กิจเตียกี่2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146957	2017-08-06 11:33:18
1095	เจริญทอง3(2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146958	2011-02-11 16:08:12
1096	ทองพิมาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146959	2025-09-10 13:33:37
1097	ทรัพย์ทวีกาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146961	2020-01-07 17:02:24
1098	ภาสวรรณบางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146962	2013-09-01 12:19:31
1099	รุ่งเรือง(บางใหญ่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146963	2020-02-28 16:54:53
1100	เพชรรัตน์บ้านแพง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146964	2021-09-18 09:42:11
1101	ฮั้วเส็งเฮง(สีลม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146965	2022-07-30 15:16:19
1102	เฮงอนันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146967	2025-03-27 14:02:33
1103	นิยมไทยนครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146968	2011-06-15 16:23:32
1104	ฮวงฮุยเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146969	2024-04-10 15:09:34
1105	เยาวราชแวงใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146972	2025-05-31 15:32:34
1106	หงษ์ทองห้วยปราบ(ระยอง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146973	2014-01-16 15:39:50
1107	ลุ้ยล้วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146974	2016-09-22 10:33:31
1108	กิจเตียกี่1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146975	2017-11-25 15:00:15
1109	100%พาน(อารีย์รัตน์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146977	2020-07-11 10:59:28
1110	เด่นหล้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146978	2013-04-19 17:00:57
1111	พงษ์ทองนครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146979	2025-09-04 11:51:40
1112	เยาวราชสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14698	2022-12-22 17:33:38
1113	คุณอุไร(ญาติช่างเปิ้ล)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146981	2011-02-25 16:21:37
1114	ไทยมิตรบางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146983	2012-08-25 12:34:07
1115	นายเล็กปัตตานี	-938621.17	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146984	2025-10-22 09:47:18
1116	อารยาอำนาจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146985	2022-06-24 16:13:30
1117	ไทยย่งเต็งนราธิวาส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146989	2013-11-14 11:30:21
1118	ก้งกาฮิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14699	2025-09-23 13:21:46
1119	คุณวรรณมาศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146991	2011-03-01 09:12:29
1120	แก้วสุวรรณ3กระบี่	0.00	0.000	0.000	30.400	0.000	0.000	0.000	2025-11-20 15:38:54.146992	2025-10-26 08:53:07
1121	ริมน้ำอู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146993	2025-04-29 14:11:52
1122	เยาวราช999ราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146995	2012-11-27 13:51:18
1123	ธรรมทวีตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146996	2020-01-11 17:10:50
1124	ทรัพย์ทวี(ย่านตาขาว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146997	2011-03-03 18:01:58
1125	เยาวราชสุวินทวงศ์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146998	2018-04-24 15:24:11
1126	เพชรทองอมรรัตน์	0.00	1.150	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.146999	2025-09-25 15:39:37
1127	ชั้น1ประตูน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147001	2024-07-26 16:31:01
1128	ทองสุกพัทยา(แม่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147002	2015-06-16 16:34:12
1129	ทองสุกพัทยา(ลูก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147004	2019-02-28 15:52:03
1130	ชมพุ7(1)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147006	2016-07-28 15:39:19
1131	ช่างเปิ้ล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147007	2023-04-06 13:13:48
1132	คุณส้วม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147008	2012-01-31 12:39:53
1133	โต๊ะกังกิมเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147009	2018-03-08 17:22:08
1134	สิริกาญจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147011	2025-10-14 17:01:06
1135	เพชรมณี(หนามแดง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147012	2016-09-29 17:11:43
1136	สยามเยาวราชโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147013	2022-12-25 15:11:14
1137	เยาวราชแวงใหญ่(คุณหน่อย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147014	2012-03-04 12:41:59
1138	เจริญแสงพะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147015	2023-10-18 10:54:12
1139	กิมปั้ง เพชรบุรี	-19361000.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147017	2025-10-26 10:06:46
1140	คุณเก่งดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147018	2024-11-21 16:14:24
1141	เนรมิตสัตหีบ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14702	2011-03-16 11:03:18
1142	อุษณีย์N	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147021	2011-04-06 12:33:23
1143	อุษณีย์O	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147022	2011-04-06 12:33:25
1144	อุษณีย์P	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147023	2011-04-06 12:33:26
1145	เคหะทองคำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147024	2013-01-09 14:09:13
1146	อุษณีย์Q	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147025	2011-03-22 14:33:03
1147	เยาวราชหทัยราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147027	2025-10-16 14:56:38
1148	เยาวราชคลอง7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147028	2025-03-18 11:12:30
1149	ซินหิ้น พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14703	2021-12-28 16:41:14
1150	วาเลนไทน์ลำปาง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147031	2015-05-09 10:16:46
1151	ยิ่งเจริญยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147032	2017-04-22 16:05:46
1152	เพชรทองเยาวราชตลาดพงศกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147034	2011-03-24 15:02:31
1153	อุษณีย์R	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147036	2011-03-29 14:59:25
1154	เยาวราชสุวินทวงศ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147037	2019-05-09 16:35:27
1155	รักไทย กรุงเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147038	2015-05-05 08:53:22
1156	สินชัย ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14704	2025-07-29 15:11:16
1157	นัชชาปราจีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147041	2023-07-16 14:56:19
1158	แสงอรุณสุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147042	2016-04-23 15:38:40
1159	แม่ทองใบรามอินทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147043	2011-08-05 14:53:45
1160	สมสมร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147044	2014-09-28 14:55:38
1161	เหง่าย่งเฮงนราธิวาส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147045	2018-02-10 12:53:57
1162	เยาวราชคลอง4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147046	2025-10-08 11:15:05
1163	จิราพรชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147047	2023-03-07 15:58:20
1164	นนทชัยบางใหญ่	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.147048	2025-10-07 16:36:38
1165	ศรีโต๊ะกังเซ็นจูรี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14705	2025-10-02 15:33:35
1166	เยาวราชหนองกี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147052	2011-04-07 12:33:55
1167	ทวีพรรณ(สุโขทัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147055	2011-04-07 17:52:53
1168	สมฤทธิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147056	2025-10-22 10:36:58
1169	สุขสวัสดิ์เมืองกาญจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147057	2025-06-29 14:42:18
1170	คุณเก๋	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147058	2025-04-10 13:00:32
1171	พีระพงษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147059	2020-06-21 15:54:23
1172	แม่หงษ์บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14706	2024-12-18 16:36:09
1173	ทองน้ำหนักเต็ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147061	2020-11-28 10:03:52
1174	จังเจริญชัย(คุณต่อ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147062	2011-04-20 14:39:18
1175	สิริกาญจน์(วิภา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147063	2014-07-02 09:04:08
1176	ณ นนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147064	2025-10-21 16:26:54
1177	นิดา ย่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147066	2011-07-27 14:34:25
1178	ช่างอู๋(นก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147068	2024-01-06 15:23:36
1179	อากงเยาวราชขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147069	2025-10-16 18:04:24
1180	อิดล้ง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147072	2013-09-03 12:38:19
1181	แสงทองใบ(สมชัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147073	2025-09-10 14:30:02
1182	หวังสินไทย2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147074	2025-06-14 09:35:09
1183	ไท้เฮงหลีหนองตม(พิษณุโลก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147075	2017-01-08 15:40:50
1184	สถาพรดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147076	2014-02-25 09:51:31
1185	เยาวราชสุวินทวงศ์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147077	2018-04-21 11:20:36
1186	ศรีโต๊ะกังเซ็นเตอร์วัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147078	2025-10-11 12:54:48
1187	ดีเฮงเยาวราชแก่งคอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147079	2025-07-24 11:46:11
1188	กิมเล่งเฮง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147081	2023-06-22 16:37:48
1189	เหงี่ยมเซ่งเฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147082	2011-09-08 11:45:16
1190	วีระพงศ์นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147084	2015-09-30 13:07:24
1191	ธนาทองโกลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147085	2021-12-16 11:05:14
1192	100%พาน(วรวีร์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147086	2021-11-16 08:57:11
1193	มาลีสวัสดิ์ทุ่งใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147087	2011-05-09 15:37:31
1194	มารยาท(บุรีรัมย์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147088	2024-05-29 11:56:57
1195	พูนทองเชียงคำ	-336274.62	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14709	2025-10-21 15:48:34
1196	อุษณีT	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147091	2011-07-13 10:30:29
1197	วรรณพร(เชียงราย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147092	2024-02-27 16:44:53
1198	อุษณีS	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147093	2011-07-13 10:30:26
1199	หงษ์ทองห้วยปราบระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147094	2011-05-08 09:42:07
1200	คิ้งเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147095	2019-10-20 11:18:33
1201	100%อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147096	2022-01-05 16:07:47
1202	สยามเยาวราช(แนน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147099	2015-05-09 16:26:07
1203	อุษณีU	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1471	2011-05-29 09:21:32
1204	อิดล้ง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147102	2017-03-22 12:59:50
1205	อุษณีV	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147103	2011-07-13 10:30:51
1206	เยาวราข999ราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147103	2012-12-27 13:14:34
1207	เยาวราชบุณฑริก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147104	2014-12-21 15:47:14
1208	เพชรทองเมืองเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147105	2011-05-11 15:22:30
1209	ทวีทรัพย์เชียงคำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147107	2025-04-25 15:36:37
1210	เจริญทรัพย์ชะอวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147108	2025-08-03 14:17:16
1211	ทองหยก1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147109	2025-01-17 14:34:33
1212	เยาวราชแปลงยาวบางบ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147114	2021-03-23 16:36:03
1213	เยาวราชเขาวงกาฬสินธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147115	2015-09-01 16:08:18
1214	โชคอนันต์แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147117	2011-05-22 16:57:26
1215	วันชัยอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147118	2011-08-21 12:06:25
1216	เยาวราชเทพารักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14712	2022-03-15 17:38:36
1217	ลักกี้เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147121	2018-09-23 09:35:34
1218	โชคทวีอำเภอจุน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147122	2011-05-26 11:24:52
1219	36กะรัต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147123	2011-06-21 17:10:20
1220	แม่ทองใบแจ้งวัฒนะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147124	2015-07-01 13:20:25
1221	รุ่งเรืองบางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147125	2020-02-25 13:33:16
1222	จิ้นฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147126	2012-04-11 17:54:48
1223	ตุ้นเฮงหลี(เจ๊เข่ง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147127	2014-05-18 15:45:58
1224	คุณสิริมนัส(ญาติพี่จิตรลดา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147128	2011-08-25 14:32:19
1225	เพชรทองดีลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147129	2011-06-04 17:08:37
1226	นนทชัยตลิ่งชัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147132	2021-08-24 11:07:58
1227	สิงห์รุ่งเรือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147133	2018-05-27 14:07:17
1228	บุญเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147134	2022-12-23 18:07:40
1229	เจริญทอง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147136	2024-11-03 12:57:07
1230	ปอเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147137	2025-06-20 15:41:53
1231	ทองหยก2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147138	2019-11-13 17:32:20
1232	ศรีโต๊ะกังบารอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14714	2025-09-24 14:16:21
1233	เจ็งลีเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147141	2011-08-24 13:42:46
1234	คุณปลาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147142	2013-08-13 10:42:37
1235	คุณปราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147143	2013-02-16 13:05:26
1236	เยาวราชสุขสันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147144	2025-10-04 14:34:27
1237	มังกรสามพราน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147146	2020-01-05 12:59:15
1238	สกุลทองสุไหงโกลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147148	2016-06-14 16:28:39
1239	ศรทอง(พ่อ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147149	2018-06-16 14:13:01
1240	ศรทอง(แม่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14715	2025-10-22 11:15:42
1241	เสียมไทยเซี้ยง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147152	2015-07-18 13:50:22
1242	โชคดีรังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147153	2014-11-26 15:20:02
1243	พูนพล	0.00	150.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147154	2025-09-03 16:15:22
1244	มณีภัณฑ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147157	2011-06-23 14:53:14
1245	ซิมเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147158	2011-10-08 13:50:50
1246	ทองสุกเยาวราช(บี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147159	2025-06-22 11:42:04
1247	ช่างวิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147161	2019-06-25 10:30:32
1248	เด่นแสงหาดใหญ่	228.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147162	2011-07-26 00:00:00
1249	ใต้ฟ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147163	2016-03-03 14:10:49
1250	เอก2ศักดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147166	2022-10-21 16:00:17
1251	น้องฮกกี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147167	2016-09-29 11:43:19
1252	เยาวราชชากค้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147169	2023-12-12 17:06:16
1253	กาญจนกิจ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147171	2022-01-28 17:02:44
1254	คุณชญาน์กาญน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147172	2020-04-24 08:58:49
1255	พนักงานแตง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147173	2022-04-24 12:57:54
1256	จินเซ่งเฮงสายทิพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147174	2025-10-25 11:10:58
1257	ไทยเจริญกำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147175	2015-08-25 12:14:46
1258	เฮียมัน(พี่หนู)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147176	2022-03-12 09:35:02
1259	เตชิตปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147177	2012-01-20 14:41:08
1260	คุณอู๊ด(นำเจริญ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147178	2011-07-07 09:42:47
1261	เยาวราชท่าชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14718	2013-03-12 11:15:22
1262	คุณโห้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147182	2012-05-23 10:38:55
1263	นายห้างอัศวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147183	2024-05-10 09:46:09
1264	อึ้งฮั่วเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147184	2015-06-02 15:59:49
1265	คุณก๊อป(ทองทิพย์อำนาจเจริญ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147186	2011-07-12 10:10:58
1266	คุณหน่อย(ทองทิพย์อำนาจเจริญ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147187	2011-07-14 11:46:00
1267	วังทอง3พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147188	2012-01-28 14:12:12
1268	อินเตอร์ปัตตานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14719	2016-12-11 13:27:23
1269	ดาวทองบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147191	2018-11-22 16:30:45
1270	แม่นกเล็กสุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147192	2015-09-06 13:22:56
1271	ปรีชาสุวรรณ(สุราษฎร์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147193	2011-07-12 12:48:51
1272	อมรสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147194	2024-10-24 14:21:17
1273	คุณโกวิทย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147195	2011-10-05 10:06:13
1274	แม่ยินดีแปดริ้ว(พี่สาว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147198	2012-01-06 14:13:32
1275	แม่ยินดีแปดริ้ว(ชนกพร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147199	2011-07-26 12:01:00
1276	เพชรราชา(สะพานเหล็ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147201	2011-09-12 17:37:55
1277	แมกิมหงษ์เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147202	2013-02-23 15:33:18
1278	ทองคำเยาวราช(อำนาจเจริญ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147204	2013-03-09 11:33:33
1279	ไทยมิตรบางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147205	2025-10-24 15:47:15
1280	เจริญศรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147206	2011-09-25 15:16:57
1281	จังเจริญชัย โรงสี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147207	2012-04-11 15:52:23
1282	สินทวี(เชียงราย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147208	2011-07-26 09:12:20
1283	คุณรัตน์(คุณแน๊ต)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147209	2013-02-26 09:43:16
1284	ฮกจ๋ายภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14721	2025-10-17 16:31:46
1285	ฮั้วหงษ์แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147211	2016-06-21 10:48:29
1286	คุณชฎา(พี่สาวกมลรัตน์825)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147214	2012-06-26 11:23:10
1287	คุณศศิณี(เพื่อนคุณชฎา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147215	2011-08-10 14:11:26
1288	เพชรไพลิน1(ซ้อไน้)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147216	2011-08-15 09:41:18
1289	สุมิตรา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147217	2015-07-22 10:03:59
1290	เยาวราชศีขรภูมิสุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147218	2016-02-03 00:00:00
1291	ศิริรัตน์นำโชค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147219	2011-07-31 09:51:10
1292	ชนาธิป(ลูกชายเฮียนึก)	-99887.00	2236.350	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14722	2025-10-25 15:11:33
1293	เยาวราชตลาดไท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147221	2019-12-04 14:36:13
1294	พรสุพรรณแม่(คลองตัน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147222	2016-03-04 16:55:07
1295	หลักเฮง(ศิริศักดิ์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147224	2012-09-18 12:21:52
1296	99เยาวราชนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147225	2018-10-07 14:56:50
1297	พรสุพรรณโลตัสศรีนครินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147226	2023-01-26 15:18:16
1298	พรสุพรรณ(สุทธิสาร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147228	2016-11-18 10:01:37
1299	ช่างอุ๊	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14723	2016-09-30 21:03:41
1300	เฮียอุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147231	2011-08-06 12:02:35
1301	ทองสิริทรัพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147232	2011-08-06 15:03:58
1302	เยาวราชวังม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147233	2018-12-02 12:05:35
1303	คุณฐิติวัฒน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147235	2012-09-06 13:18:33
1304	อุษณีย์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147236	2015-07-21 10:36:40
1305	อุษณีย์3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147237	2024-08-20 16:00:02
1306	อุษณีย์4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147238	2024-08-20 15:57:38
1307	อุษณีย์5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147241	2014-06-11 14:22:15
1308	พรเจริญ2มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147242	2020-12-24 13:06:15
1309	พรเจริญยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147243	2020-08-01 09:45:07
1310	รัตนาอ้อมใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147244	2011-08-27 14:28:15
1311	ห้างเพชรทองแสงรวี(แสงรวี2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147247	2025-10-07 11:20:02
1312	กุลศรีสุวรรณ(คุณนัท)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147248	2011-09-29 10:19:10
1313	อุษณีย์6	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147249	2024-08-30 13:57:40
1314	อุษณีย์7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14725	2011-08-17 12:26:49
1315	อุษณีย์8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147251	2011-08-25 11:33:10
1316	อุษณีย์9	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147252	2011-08-28 10:15:56
1317	อุษณีย์10	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147253	2011-08-28 10:16:25
1318	คุณหนิ่ง(คุณแจ๋ว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147254	2020-07-23 10:15:25
1319	คุณหน่อย(คุณแจ๋ว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147255	2013-06-13 09:39:37
1320	สยามเยาวราช(อร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147256	2015-11-21 11:52:08
1321	สวนมะลิ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147257	2012-01-05 11:48:14
1322	พรเจริญ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147258	2011-08-24 10:19:43
1323	แสงทองใบ1จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147261	2011-11-03 09:33:16
1324	เยาวราชจันทรเกษม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147262	2016-09-29 18:18:05
1325	โต๊ะกังฟอร์จูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147263	2016-09-30 13:45:21
1326	แม่หงษ์บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147264	2012-12-28 12:10:13
1327	หย่งฮะเชียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147265	2020-06-21 09:15:08
1328	วงศ์มณี บางปะกง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147266	2025-10-21 15:45:38
1329	ฉั่วเม่งสุน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147267	2024-11-23 15:23:21
1330	คุณเทอดศักดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147268	2011-12-20 11:23:37
1331	เยาวราชมุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147269	2023-03-24 15:23:46
1332	คุณสมศักดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14727	2016-11-09 13:42:52
1333	คุณแป๋ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147271	2012-12-19 12:15:33
1334	คุณไพจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147273	2016-03-30 12:20:17
1335	คุณชัยชาญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147275	2020-04-15 11:20:31
1336	เยาวราชสหพัฒน์วัดไทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147277	2012-10-10 09:19:08
1337	อุษณีย์11	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147279	2012-03-06 13:28:53
1338	อุษณีย์12	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14728	2012-01-17 15:25:53
1339	เมืองทองสกล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147283	2016-02-26 09:13:35
1340	แสงทองใบ1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147284	2012-07-22 09:36:11
1341	หย่งฮะเส็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147285	2019-06-12 12:52:59
1342	ปุ๊กพนักงาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147286	2025-10-24 10:49:36
1343	ทิพย์ทองชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147287	2018-09-08 11:22:00
1344	จังเจริญชัยโรงสี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147289	2011-09-04 09:43:14
1345	สุมิตรา1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14729	2014-12-02 11:35:38
1346	ฮ้วนซินหลี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147291	2012-02-19 14:03:54
1347	ช่างส้ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147294	2016-09-30 21:04:18
1348	ช่างประทิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147295	2025-06-04 12:58:42
1349	แสงนภา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147296	2011-09-08 13:14:31
1350	คุณกิ่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147297	2011-09-09 09:33:39
1351	คุณกัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147298	2015-04-01 14:25:37
1352	เจ็งบ้วนสุน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147299	2016-01-20 17:02:50
1353	เพชรทองดีสุขสันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1473	2016-01-07 10:46:03
1354	เชียงราย นพคุณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147302	2017-06-18 10:24:42
1355	เยาวราชนาคู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147303	2015-09-01 16:10:45
1356	ทองคำแพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147303	2012-03-15 16:41:56
1357	ริมน้ำ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147305	2011-10-26 00:00:00
1358	คุณริน(เพื่อนหลักเฮง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147306	2012-05-10 17:16:25
1359	เยาวราชกรุงเทพกันทรารมย์คุณไก่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147308	2012-01-27 13:14:54
1360	พรเจริญกาฬสินธิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14731	2016-09-04 15:00:58
1361	เยาวราช9คลองสอง 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147376	2020-04-14 14:59:45
1362	คุณบอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147378	2020-04-30 09:11:59
1363	เฮียบั๊ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147379	2014-12-11 14:21:54
1364	เพชรทองกิมคุง(111)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14738	2016-09-18 15:10:50
1365	เยาวราชศิขรภูมิสุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147381	2015-08-23 11:30:22
1366	คุณณัฐพล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147382	2022-03-17 10:55:53
1367	เยาวราชหนองปรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147383	2011-09-21 14:49:38
1368	เอกเซ่งเฮง2 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147384	2011-10-14 09:30:06
1369	รัศมีเยาวราช1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147385	2011-09-22 10:23:22
1370	หลักเฮงศิริศักดิ์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147386	2011-11-03 16:19:04
1371	พรสุพรรณแม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14739	2013-12-17 14:52:00
1372	เยาวราชหทัยราษฏร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147391	2020-04-03 16:16:10
1373	เยาวราชศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147392	2011-12-30 17:24:42
1374	เซ่งฮวด เขมราฐ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147394	2022-11-04 16:04:44
1375	วิวัฒน์พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147395	2019-04-24 14:16:43
1376	โชคชัยน่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147396	2017-12-10 10:56:22
1377	ลิขิตชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147397	2018-09-29 17:21:52
1378	ปลีก2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147398	2025-10-24 10:33:32
1379	ปลีก3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1474	2025-10-17 12:29:29
1380	ปลีก4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147401	2025-10-17 17:07:40
1381	ปลีก5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147402	2024-07-12 15:26:59
1382	ปลีก6	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147404	2024-05-15 17:14:21
1383	ปลีก7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147406	2022-03-09 14:48:54
1384	ปลีก8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147407	2022-03-09 16:18:02
1385	ปลีก9	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147409	2022-03-09 16:41:36
1386	ปลีก10	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14741	2024-05-21 16:51:27
1387	เยาวราชสุราษฏร์(อาอี้ยุพิน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147411	2020-07-21 11:26:14
1388	คุณเซ้ง(ฮั้วสูน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147413	2020-07-25 08:59:05
1389	สแตนเลส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147414	2015-01-16 12:47:28
1390	คุณผจกท.พ.	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147415	2011-10-18 09:09:27
1391	คุณน้องคุณมาลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147416	2019-07-19 10:53:43
1392	อัญชลี(ญาติเอก2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147418	2012-12-27 12:53:51
1393	คุณญาติปุ๊ก	0.00	0.000	0.000	762.200	0.000	0.000	0.000	2025-11-20 15:38:54.147419	2025-10-24 16:29:25
1394	คุณซ้อจำไม่ได้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14742	2013-07-03 15:41:48
1395	หงษ์ทอง3ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147423	2012-09-08 12:30:44
1396	คุณพรรณรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147424	2012-09-18 09:03:53
1397	ซุ่นเซ่งเฮง(แจ๊ค)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147426	2011-09-27 14:37:26
1398	เฮงเส็งเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147427	2012-08-17 13:25:18
1399	คุณวนิดา(เพื่อนหลักเฮง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147428	2012-01-26 14:31:09
1400	เพชรมณีหนามแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147429	2016-02-02 11:17:29
1401	คงคา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14743	2025-09-15 15:18:05
1402	เยาวราชศิขรภูมิ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147431	2016-02-02 15:27:24
1403	เฮียเพียว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147434	2018-03-13 14:59:42
1404	เฮียเล้งหนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147435	2011-10-11 15:23:54
1405	คุณไพศาล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147436	2023-02-02 10:18:21
1406	คุณธวัชธิดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147437	2011-10-05 14:55:08
1407	พลอยเพชรรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14744	2014-03-27 11:53:17
1408	เหมี่ยวพนักงาน	100000.00	0.000	0.000	61.000	0.000	0.000	0.000	2025-11-20 15:38:54.147441	2025-10-22 16:20:32
1409	ช่างแหม่ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147442	2025-10-24 17:10:47
1410	เยาวราชบางปะกอก3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147443	2016-11-03 13:25:41
1411	ทองธรรศจันทรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147444	2022-04-16 10:00:15
1412	เพชรสุวรรณระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147445	2025-10-24 16:56:30
1413	เยาวราชแวงน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147447	2013-04-25 00:00:00
1414	บ้านทองเยาวราชพิจืตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147448	2025-06-29 13:49:25
1415	แก้วแสงทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14745	2018-09-20 17:09:15
1416	คุณวัฒนา(เยาวราชบางปะกอก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147451	2016-11-03 13:43:51
1417	นครพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147452	2016-09-18 12:53:21
1418	ตั้งเซ่งเฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147453	2025-10-03 11:32:17
1419	คุณวาสนาvs	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147455	2024-09-24 15:05:48
1420	ยิ่งเฮงตลาดพูล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147457	2012-05-19 11:21:07
1421	รวมสุวรรณบางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147458	2025-10-24 15:12:37
1422	0%นวมินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147459	2020-03-02 00:00:00
1423	พงษ์เจริญเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147462	2017-11-10 13:19:29
1424	สุวรรณมณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147463	2023-08-04 16:04:19
1425	ช่างจิ้งเซี้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147464	2016-02-12 14:02:38
1426	อินเตอร์4หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147465	2013-12-28 15:07:22
1427	อินเตอร์3หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147466	2016-07-08 15:46:18
1428	คุณปวีณา(ศุภกิจ19)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147468	2025-09-19 15:22:26
1429	กิเลน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147469	2016-01-28 10:45:07
1430	สยามเยาวราชโคราช2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14747	2020-03-19 13:18:35
1431	สามดาว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147473	2025-10-22 12:29:27
1432	ซุ่นเซ่งเฮง(อุดมสุข)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147474	2024-12-25 12:10:51
1433	แม่สง่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147475	2020-01-17 15:53:25
1434	กิมโต๊ะกังลำลูกกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147477	2011-12-07 14:16:41
1435	กเยาวราชตะพานหิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147478	2019-06-23 13:42:47
1436	เยาวราชจันทรเกษม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14748	2025-09-05 15:38:14
1437	ชัยเจริญ2(2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147481	2012-11-27 15:34:31
1438	ศรีทองใบสวนพลู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147482	2011-10-18 00:00:00
1439	อึ้งฮะเฮงชัยนาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147483	2025-10-18 15:11:02
1440	เทพสิริกาญจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147485	2015-06-11 16:21:08
1441	คุณป๊อ(น้องเฮียจิว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147486	2011-10-20 16:20:50
1442	เฮียเน้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147487	2025-10-25 15:10:54
1443	คุณวัชระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147489	2020-04-25 10:10:40
1444	แม่ประเทืองหนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14749	2025-02-26 15:38:06
1445	โต๊ะกังนิวสตาร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147492	2022-11-10 15:51:59
1446	กรุงนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147493	2016-10-13 13:38:32
1447	สุวรรณหงษ์ดาวคะนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147494	2025-06-13 14:50:09
1448	ไพบูลย์1 มวกเหล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147495	2025-09-04 14:01:10
1449	แม่ยินดีเพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147496	2025-09-04 15:10:37
1450	เพชรเกษร(บางลำภู)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147497	2011-11-02 09:14:55
1451	บุญชัยอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147498	2022-03-17 10:59:27
1452	บุญทรัพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147499	2012-07-11 12:59:23
1453	มาลัยทองนครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1475	2016-09-27 16:11:37
1454	แสงมณีบ้านโป่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147501	2013-02-16 16:24:15
1455	แม่ยินดีปร2(อุทัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147502	2012-05-03 09:18:49
1456	แม่เกิดมี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147507	2022-03-15 09:18:22
1457	ช่างนก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147508	2016-10-07 13:58:13
1458	เยาวราชท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14751	2020-04-15 08:54:07
1459	ศรีวารี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147511	2014-11-29 11:15:31
1460	ก๊วยเซ่งเฮง(พระประแดง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147512	2016-12-14 16:52:56
1461	ยินดีสุไหงโกลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147513	2017-04-29 16:32:34
1462	จารุวัฒน์ช้างเผือก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147514	2015-09-25 13:03:48
1463	เก้ามณี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147515	2012-02-02 14:04:40
1464	เพชรถาวร(เพชรบูรณ์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147516	2021-04-24 13:50:50
1465	วังทอง2(2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147517	2016-09-29 12:07:34
1466	ศรีเจริญโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14752	2015-03-06 12:18:50
1467	อันเชียงเซ็นทรัลราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147521	2022-12-27 14:55:28
1468	แม่กิมหงษ์บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147523	2022-04-23 14:25:17
1469	ฮวดเซ่งเฮง(เฮียสี่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147525	2019-07-03 13:14:16
1470	มาสเตอร์โกลด์เยาวราชสงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147526	2019-10-26 17:23:49
1471	ทองดีอำนาจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147527	2017-05-16 16:47:06
1472	เพชรสมใจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147529	2021-09-04 12:25:17
1473	เจริญศรี(ศรีสะเกษ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147529	2025-05-20 13:04:30
1474	พัฒนาสมอทอด2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147531	2016-07-09 15:46:36
1475	เยาวราชบางปะกอก2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147532	2021-10-15 08:53:49
1476	บีอาภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147533	2016-06-30 11:00:54
1477	ทองส่องแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147534	2014-12-03 13:08:15
1478	เพชรทองใบลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147535	2017-11-26 15:04:46
1479	คุณปฎิพล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147536	2017-11-10 17:19:26
1480	ตั้งเซียมเฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147538	2025-10-15 09:36:23
1481	ชุนหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147539	2011-12-03 17:21:15
1482	รุ่งเรืองชนแดน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14754	2011-12-04 11:07:00
1483	อุดมชัยขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147541	2025-10-19 15:13:00
1484	ยุพาแปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147542	2019-11-21 16:12:18
1485	คุณวราภรณ์(เพื่อนคุณชฎา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147543	2012-02-13 13:44:26
1486	ทองใบนนทบุรี	0.00	0.000	0.000	457.300	0.000	0.000	0.000	2025-11-20 15:38:54.147544	2025-10-24 17:12:28
1487	เพชรทองบางขันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147545	2011-12-24 19:57:15
1488	ศรีโต๊ะกังธัญบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147546	2011-12-24 13:10:38
1489	ทองพันชั่ง(คุณจิ๋ว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147547	2018-12-26 16:20:47
1490	กรุงเทพ(เปิ้ล)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147548	2011-12-12 11:13:49
1491	ดีดี(ณี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147549	2011-12-25 11:38:45
1492	100%ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147551	2025-05-10 14:36:24
1493	สมใจ2นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147552	2018-05-05 16:40:09
1494	คุณเปิ้ล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147553	2022-12-27 12:53:57
1495	เอกภัณฑ์(วรภพ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147554	2012-09-23 10:15:36
1496	ปรียา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147555	2016-09-22 11:23:31
1497	ทองทวี1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147556	2016-02-17 15:25:04
1498	เยาวราชเชียงของ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147559	2020-05-17 08:49:37
1499	คุณเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14756	2012-04-27 18:30:10
1500	น้ำทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147561	2013-03-13 15:05:52
1501	ช่างผึ้ง(เฮีย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147562	2012-05-10 18:01:57
1502	ตั้งเซ่งฮวดท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147563	2018-01-05 16:45:48
1503	ไทยศิลป์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147564	2024-02-21 16:26:27
1504	ทรัพย์ทวีสตูล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147567	2025-08-26 11:12:56
1505	เยาวราชกระทุ่มแบน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147568	2019-12-04 17:56:38
1506	คุณจุ้ย(ช่างไฟ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147568	2024-04-03 10:41:09
1507	ดีทองดีเยาวราช ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147571	2020-11-15 13:50:57
1508	ทองวิสุทธิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147572	2025-05-14 10:08:54
1509	อุษณี13	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147573	2024-12-12 15:30:07
1510	อุษณี14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147575	2024-12-12 15:30:11
1511	คุณซุ้ยเพ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147576	2019-08-28 10:29:59
1512	อุษณี15	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147577	2012-05-08 11:53:04
1513	พรพรรณขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147578	2022-10-05 09:47:12
1514	อ้อยทองดี1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147579	2016-02-11 13:30:19
1515	คุณน้องเฮียจิว(เชษฐ์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147579	2015-08-20 15:35:14
1516	คุณน้องเฮียจิว(วันชัย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147582	2016-04-08 12:26:38
1517	คุณตั้งเจ็กบางขุนเทียน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147583	2011-12-17 15:24:35
1518	เพชรสุภาภรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147584	2024-09-17 14:10:58
1519	พิบูลย์อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147585	2012-07-22 10:13:31
1520	อุษณี16	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147586	2011-12-18 11:14:41
1521	เยาวราชสำโรงวัดด่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147587	2013-08-29 16:11:01
1522	ทวีทรัพย์ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147588	2014-06-29 10:14:50
1523	แห้วดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147589	2012-03-01 15:46:42
1524	จี้ซิน(น้อง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14759	2022-09-22 14:39:08
1525	คุณน้องจี้ซิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147591	2020-03-10 11:13:33
1526	โต๊ะกังเจซี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147592	2011-12-20 14:08:57
1527	ทอมสัน2หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147593	2023-02-10 17:14:21
1528	คุณธนเดช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147595	2016-07-08 13:41:56
1529	เอกเซ่งเฮง(สุบิน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147596	2020-07-14 10:47:38
1530	โอ๋พนักงาน	0.00	2.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147599	2025-10-22 16:18:51
1531	กเยาวราชบ้านสร้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1476	2012-02-05 12:13:16
1532	ภัณฑสิน เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147601	2022-09-03 15:29:26
1533	ภัณฑสิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147602	2011-12-24 13:00:37
1534	กิมโต๊ะกังธัญบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147603	2012-01-10 12:28:46
1535	เยาวราชวรรณรักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147604	2012-11-13 17:01:58
1536	นำทองเยาวราชบางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147605	2025-03-15 13:26:25
1537	ฟ้าไทยพิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147606	2017-05-21 13:34:03
1538	ไนโตรเคมี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147607	2013-11-05 10:45:37
1539	ตสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147608	2015-07-18 13:00:55
1540	แม่จันทร์เพ็ญ(เมือง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14761	2024-10-26 09:21:40
1541	แม่จันทร์เพ็ญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147612	2016-12-17 17:31:51
1542	อุษณี17	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147613	2012-03-01 16:32:01
1543	อุษณี18	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147614	2012-06-24 11:45:22
1544	อุษณี19	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147616	2012-06-26 12:15:38
1545	อุษณี20	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147617	2012-06-26 12:15:55
1546	หลานยี่เฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147617	2025-10-24 16:00:04
1547	ชูแสงทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147619	2015-09-25 12:26:00
1548	แม่นกเล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147619	2013-07-19 09:46:00
1549	ศรทองกำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14762	2013-06-07 11:16:17
1550	ทองธเนศเจ้าฟ้าภูเก็ต	0.00	1587.500	0.000	838.350	0.000	0.000	0.000	2025-11-20 15:38:54.147622	2025-10-24 17:00:42
1551	กรุงไทย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147623	2013-08-01 15:56:16
1552	ภูเก็ต2(ซุปเปอร์ชิป)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147626	2019-01-23 17:07:51
1553	คุณต้อมMT	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147627	2012-01-26 10:39:32
1554	ภูเก็ต(โลตัสเจ้าฟ้า)	-677427.16	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147628	2025-10-25 15:06:38
1555	ออโรร่าอุดมสุข	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147629	2017-09-27 10:04:43
1556	ออโรร่าอุดมสุข(พัชร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14763	2012-01-04 16:50:52
1557	ออโรร่า(พี่พริก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147631	2012-01-04 16:29:58
1558	มรกตหนามแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147632	2025-10-04 15:38:25
1559	เยาวราชศรีเมืองใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147633	2017-08-09 13:28:51
1560	ทวีทรัพย์หนองแขม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147635	2018-03-01 10:20:44
1561	กรุงเทพ(ระยอง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147637	2012-04-24 11:26:39
1562	นิยมพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147638	2017-04-09 14:55:54
1563	พรเจริญนิคม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147639	2022-08-27 13:50:26
1564	นริศรา22	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147641	2013-02-21 09:58:32
1565	แสงทอง1แม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147643	2024-05-16 16:03:33
1566	เหรียญทองนครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147643	2012-05-17 14:36:51
1567	พรทวีนนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147644	2012-01-10 18:59:36
1568	เจริญกรุงเยาวราชบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147645	2021-03-06 18:32:45
1569	เอ็งจุ่งฮวดอุดรธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147646	2012-01-11 18:36:12
1570	ยิ่งเจริญมุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147647	2013-05-07 18:24:08
1571	จินเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147648	2014-12-12 16:25:14
1572	ก้วงง้วนราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147649	2012-01-13 13:15:32
1573	สมบูรณ์พาณิชย์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14765	2012-01-14 09:56:24
1574	ยงเจริญมุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147651	2022-04-30 15:57:15
1575	แสงชัยเพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147652	2022-03-09 17:20:35
1576	เจริญทวีพังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147654	2012-01-17 11:02:05
1577	พนักงานติ๊ก(ชาย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147655	2025-10-01 11:46:17
1578	บีอาด่านนอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147657	2022-08-13 15:20:34
1579	คุณปลา(คุณบัณฑิต)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147658	2012-01-20 13:14:16
1580	เยาวราชนำโชค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147659	2012-01-20 15:50:55
1581	ธนทองเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14766	2015-03-11 17:29:48
1582	นาทีทอง3กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147661	2012-01-21 11:16:45
1583	ดารณี1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147662	2014-10-18 14:45:36
1584	เยาวราชศรีเมืองใหม๋2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147663	2020-02-29 14:11:52
1585	ช่างจิว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147664	2025-09-30 12:33:50
1586	รวมสาสน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147665	2022-03-08 13:45:15
1587	คุณโกวเอ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147666	2025-09-24 11:27:20
1588	ไทยทองดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147669	2012-01-27 12:17:08
1589	แสงสุวรรณ1สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14767	2014-12-27 14:46:17
1590	แสงสุวรรณ3สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147671	2014-09-17 15:51:26
1591	ม้าสุวรรณดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147672	2022-05-21 15:44:35
1592	ไทยวานิชปากเกร็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147674	2020-04-29 13:46:44
1593	ช่างแอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147677	2016-10-01 13:46:15
1594	ไทยวิจารณ์บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147678	2014-01-27 10:24:32
1595	คุณธีระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147679	2016-02-19 13:59:13
1596	สุวรรณศิลป์ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147679	2017-08-05 17:14:43
1597	แสงจันทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14768	2012-02-03 14:15:13
1598	ส.เจริญชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147682	2012-02-04 16:32:12
1599	ฟิตรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147682	2012-09-04 18:17:04
1600	ยี่เชียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147683	2012-02-07 10:55:40
1601	นพเก้ากำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147686	2015-08-18 15:02:51
1602	เยาวราชลำลูกกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147687	2012-07-06 13:00:22
1603	คุณสุ(VIP)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147688	2024-10-17 13:36:10
1604	เอกชัยระนอง(แม่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147689	2012-02-07 15:09:49
1605	เอกชัยระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14769	2012-02-07 13:45:15
1606	เอกชัยระนอง(ลูก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147691	2012-02-07 15:10:05
1607	โต๊ะกังสะพาน4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147692	2024-07-05 11:52:27
1608	พญานาคสระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147693	2018-01-19 15:34:32
1609	บุญอุดมภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147694	2022-10-19 16:02:11
1610	เพชรไพลินไชยา สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147695	2022-08-04 14:52:28
1611	เพชรไพลินไชยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147696	2012-02-09 15:38:38
1612	เพชรทองสุก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147697	2012-02-26 14:58:52
1613	กนกนภาชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147699	2018-02-27 18:04:41
1614	เยาวราชคอนสวรรค์ชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1477	2012-03-10 18:01:48
1615	เสรีภัณฑ์แม่สาย(เมธา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147701	2020-02-18 10:17:31
1616	ทองประเสริฐ(นครปฐม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147702	2017-04-26 11:32:20
1617	แสงเจริญบ้านโป่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147703	2013-04-04 14:52:00
1618	กิจเจริญ(ปราจีนบุรี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147704	2017-05-16 17:17:21
1619	สมใจ3นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147706	2019-03-24 15:35:54
1620	ทองสัมพันธ์1จันทบุรี	0.00	31.950	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147707	2023-10-20 15:33:27
1621	บุญทรัพย์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147708	2012-02-23 17:18:42
1622	เยาวราชบางน้ำเปรี้ยว2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147709	2014-07-02 16:38:27
1623	เพชรทองพุทธรักษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14771	2021-02-05 15:47:14
1624	บุญเลิศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14771	2024-11-20 15:56:46
1625	ไทยดีภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147714	2015-10-08 15:10:10
1626	งามเจริญแม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147715	2012-06-15 00:00:00
1627	แม่จู(ประจวบ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147716	2013-09-28 12:50:52
1628	คุณหลีเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147717	2013-04-20 09:47:38
1629	สวัสดีสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147718	2022-12-18 15:47:15
1630	สง่าน่าน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147719	2016-03-05 15:08:48
1631	อังคณานครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147721	2025-08-17 09:41:06
1632	พงษ์สว่างกระทุ่มแบน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147722	2024-01-25 16:33:44
1633	คุณม่อน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147723	2012-03-02 14:07:57
1634	พนักงานเอ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147724	2025-10-24 17:31:03
1635	พนักงานนก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147725	2018-06-02 10:08:01
1636	ช่างเอ็ดดี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147726	2025-06-25 15:42:45
1637	คำทิพย์ตราด2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147728	2012-05-10 17:17:29
1638	สากลพิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147729	2016-09-17 00:00:00
1639	ชนันท์ชัยเภสัช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14773	2023-10-06 15:36:54
1640	ร้อยเปอร์เซ็นต์หลังสวน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147731	2021-07-11 15:44:23
1641	เพชรไพลิน(ง้วนตลาดล่าง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147732	2025-09-09 09:50:06
1642	กนกพงศ์ทับสะแก	36200.00	0.000	0.000	304.900	0.000	0.000	0.000	2025-11-20 15:38:54.147734	2025-10-24 13:11:06
1643	จินดาพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147735	2013-01-17 17:36:38
1644	ศรีเมืองสุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147736	2025-08-19 14:03:01
1645	คุณเฮงเยาวราชโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147737	2016-09-20 17:26:27
1646	สิงห์ทองคำสันป่าตอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147738	2015-08-08 15:37:10
1647	ไทยอุดมแพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147739	2025-10-19 10:22:31
1648	แม่จันทร์เพ็ญ(สันทราย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14774	2022-12-10 17:21:45
1649	เยาวราชแพรกษา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147743	2012-09-04 09:34:13
1650	คุณมงคล(ชัชวาลย์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147744	2012-08-28 09:33:16
1651	ทองเกษมบุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147745	2019-01-09 17:30:31
1652	กิมเฮงหลีบุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147746	2019-03-22 15:55:12
1653	ไท้เซ่งเฮง จู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147748	2020-02-20 10:38:49
1654	คุณน้องเฮียบั๊ก(ยุพา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147749	2014-02-20 15:14:53
1655	สกุลลักษณ์1สวรรคโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14775	2020-02-02 10:39:29
1656	สกุลรัตน์ สวรรคโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147751	2012-03-25 11:34:45
1657	กิจชัยลำปลายมาศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147753	2024-02-28 11:06:53
1658	สุวรรณรัตน์ตราด	565.00	15.650	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147754	2016-06-11 10:22:02
1659	ยิ่งเจริญบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147755	2024-09-27 11:48:26
1660	แม่บุญเรือง(ญาติ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147756	2012-03-27 11:54:04
1661	ทองดีเยาวราช บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147759	2025-03-08 13:25:07
1662	สกุลลักษณ์2สวรรคโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14776	2020-03-15 12:27:31
1663	สกุลลักษณ์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147761	2019-03-24 09:53:25
1664	ฮั่วเฮงล้ง สุขุมวิท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147762	2025-10-24 15:50:01
1665	ชื้อเซ่งเฮง บางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147763	2025-10-16 13:34:25
1666	แม่เสงี่ยม เชียงแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147764	2025-10-25 10:51:11
1667	แม่วรรณดีสุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147765	2016-06-05 10:15:05
1668	ยอดทอง ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147766	2014-11-13 16:51:12
1669	เพชรประเสริฐ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147768	2016-07-06 15:21:04
1670	เจียจินดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147769	2014-11-06 11:37:20
1671	เจียเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14777	2024-10-09 15:18:05
1672	คุณสุทธิมน(คุณขจรเดช)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147771	2014-02-25 15:00:43
1673	ปิยะพร โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147773	2012-12-06 15:18:27
1674	ทองแท้เยาวราช พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147774	2018-11-10 15:48:32
1675	ชั้นหนึ่งประตูน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147775	2012-11-03 15:19:48
1676	บ้านทองเยาวราชพิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147776	2020-06-14 11:59:36
1677	คุณชัยวัฑฒ์(ศุภกิจ19)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147779	2012-04-03 09:46:38
1678	พรเจริญอุบล2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14778	2016-09-22 16:02:08
1679	หมุยฮะ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147781	2014-01-08 12:19:27
1680	แก้วสุวรรณกระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147782	2012-04-27 14:40:26
1681	คุณซ้อเลี่ยงน่ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147783	2025-10-22 15:48:16
1682	เพชรทองเมืองทองเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147784	2015-07-21 11:10:02
1683	เทพนคร พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147785	2024-12-14 15:10:27
1684	ชัยเจริญ1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147785	2019-10-18 17:06:41
1685	สีฟ้า(แสงจันทร์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147788	2012-09-20 14:59:31
1686	นายห้างจรัญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147789	2023-07-30 14:24:27
1687	พนักงานก้อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14779	2021-12-23 16:22:24
1688	พนักงานอุ้ม	7877.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147793	2025-10-08 11:08:42
1689	ย่งไท้ฮวด(น้อง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147794	2013-04-05 15:44:56
1690	ศิริสุวรรณ พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147794	2013-02-01 14:59:18
1691	เยาวราชพัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147795	2018-05-23 11:36:31
1692	เยาวราชชุมพวง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147796	2012-05-17 11:34:14
1693	กิมเซ่งเฮง ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147798	2013-03-12 13:58:54
1694	เยาวราช8(2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147799	2012-06-06 10:13:31
1695	พรสุพรรณโลตัสศรีนครินทร์(2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1478	2012-07-05 11:29:52
1696	เกียรติมณี ฝาง	0.00	0.000	0.000	0.000	0.000	187.050	0.000	2025-11-20 15:38:54.147801	2025-10-18 11:33:27
1697	จารุกร ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147819	2025-07-20 13:06:20
1698	เยาวราชร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147821	2017-01-12 16:23:46
1699	เยาวราชนครสวรรค์ อำเภอเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147821	2023-10-21 15:46:15
1700	ตั้งฮงฮวด พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147822	2022-05-12 14:50:33
1701	แม่สมัย ญาติ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147823	2019-04-05 12:12:53
1702	เยาวราชเพชรบูรณ์ อ.เมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147824	2025-06-13 09:29:43
1703	กิตติสุวรรณ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147825	2012-05-06 10:05:07
1704	กิตติสุวรรณ2 ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147827	2013-02-24 11:34:00
1705	กมลลักษณ์ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147828	2013-12-21 16:49:34
1706	ดีเฮงเจริญ พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147829	2022-12-17 14:53:37
1707	กรุงเทพเยาวราช ศรีสำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147831	2020-08-02 16:15:45
1708	ช่างตุ๊กตา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147832	2012-05-08 14:49:20
1709	ศิริวัฒน์พนมสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147834	2025-06-24 13:25:27
1710	คุณอารีย์(พี่เฮียบัค)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147835	2025-08-28 10:27:07
1711	คุณบี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147837	2022-08-11 10:47:50
1712	คุณอาเจ็กบางขุนเทียน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147838	2012-09-14 11:39:16
1713	คุณจินดา22	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147839	2023-03-03 15:35:53
1714	สกุลลักษณ์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14784	2018-06-03 09:50:18
1715	คุณชัยวัฒน์(เพื่อนศุภกิจ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147841	2012-05-10 13:37:56
1716	คุณจอห์นนี่	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.147842	2025-09-03 15:48:35
1717	ทองแท้อุบล1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147843	2012-10-31 11:57:53
1718	วิระยะ มุดดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147844	2012-05-14 10:41:31
1719	คุณไซย้งเฮีย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147846	2012-05-14 13:36:31
1720	ออโรร่า BigC รัชดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147848	2016-06-28 12:02:57
1721	เก้ามณีอยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14785	2019-07-06 12:08:14
1722	วันฟุ้ง ปากน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147852	2012-05-17 14:24:12
1723	บ้านกรอบพระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147853	2013-07-09 11:31:21
1724	ชัชวาลย์(อาโกว)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147854	2012-05-19 17:03:45
1725	ย่งฮั่วล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147855	2025-10-03 15:34:09
1726	อุดมพรรณ5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147855	2023-06-27 13:28:54
1727	ศรีสยาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147856	2025-04-20 12:12:19
1728	เยาวราชศิขรภูมิ2(ซ้อบ๊วย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147857	2016-02-02 17:43:31
1729	หลักเซ้ง HOME	0.00	0.000	0.000	2286.500	0.000	0.000	0.000	2025-11-20 15:38:54.147858	2025-06-25 10:22:15
1730	สุประดิษฐ์ กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147859	2025-10-26 13:02:24
1731	เยาวราชโรจนะ	0.00	434.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147861	2025-10-24 16:48:35
1732	ทองไทยโคกสำโรง(ตุ๊ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147862	2016-06-28 15:00:27
1733	เพชรเจริญ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147865	2019-01-29 16:55:13
1734	ทวีโชค ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147866	2021-06-01 16:00:37
1735	นภารัตน์ ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147867	2013-08-02 16:10:38
1736	สามเพชร อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147868	2013-07-07 15:45:27
1737	สง่า มหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147869	2022-05-17 11:27:44
1738	ฮั้วเฮงเยาวราช ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14787	2012-05-27 11:05:59
1739	ฮั้วเฮงเยาวราช ห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147871	2025-10-21 15:04:56
1740	แม่กิ่งทอง4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147872	2022-07-06 16:52:12
1741	ช่างนฤพนธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147873	2016-09-30 20:13:33
1742	ถาวรรุ่งเรือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147874	2022-07-08 12:38:30
1743	ไทยมิตร ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147875	2012-06-01 00:00:00
1744	มณีรัตน์ สระแก้ว	0.00	610.150	0.000	228.650	0.000	0.000	0.000	2025-11-20 15:38:54.147877	2025-10-08 14:22:58
1745	เยาวราชบ้านโคก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147878	2018-08-18 17:39:01
1746	ไทยวิวัฒน์ พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147881	2023-02-16 15:29:35
1747	ทองอินทร์ หางดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147882	2025-09-10 13:16:48
1748	เตียเฮงล้ง สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147883	2024-10-08 16:48:38
1749	เฮงเฮง สุรินทร์	0.00	6.950	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147884	2024-02-06 17:18:30
1750	เยาวราชอุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147885	2021-04-20 16:26:25
1751	ชัยแสงเพชร เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147886	2017-08-16 16:30:18
1752	ตุ้นเฮงหลี(เจ๊หวั่น)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147889	2018-09-25 18:05:31
1753	แอ๋วพนักงาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14789	2025-06-29 09:04:36
1754	พรสุพรรณ สุทธิสาร2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147891	2013-10-24 10:57:01
1755	ทองคำเยาวราช  (รามคำแหง2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147892	2013-07-03 14:24:59
1756	เยาวราชบ้านสวน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147893	2012-07-06 13:00:04
1757	กิมไท้เฮง ประตูน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147895	2012-06-14 14:23:24
1758	พงษ์เพชร แจ้งวัฒนะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14791	2024-10-25 15:35:18
1759	เทพมณีกาญจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147911	2014-08-23 17:35:57
2034	แม่เกิดมี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148261	2020-07-23 15:21:15
1760	เยาวราช ม นเรศวร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147913	2016-06-14 14:13:11
1761	เยาวราชบางปู สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147914	2025-10-22 14:22:23
1762	สุวรรณหงษ์ เทเวศน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147915	2025-08-20 15:53:17
1763	เพชรรัตน์ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147917	2025-10-16 12:55:19
1764	ออมสิน ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147918	2025-06-04 16:31:42
1765	กรุงเทพ แกลง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14792	2025-08-14 13:28:10
1766	เยาวราชปง พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14792	2018-01-13 13:42:44
1767	ชัยมงคล คลองขวาง	0.00	0.000	0.000	609.800	0.000	0.000	0.000	2025-11-20 15:38:54.147921	2025-10-21 16:30:36
1768	คุณเจี๊ยบ น้องเฮียบัก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147923	2013-05-21 10:21:31
1769	ทองคำขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147924	2012-06-22 11:38:50
1770	จักรพรรดิ ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147927	2012-11-12 17:26:10
1771	เยาวราชทองสุก ศาลายา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147928	2012-11-25 15:09:40
1772	เยาวราชทองสุก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14793	2012-06-24 13:27:12
1773	คุณณา(เธียร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147931	2018-10-24 15:34:03
1774	เก้ามณี9 หนองแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147932	2012-08-18 17:41:55
1775	ปรียา1 สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147934	2016-02-12 09:07:16
1776	สยามเยาวราช(แนน)2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147935	2013-05-13 13:29:42
1777	โต๊ะกังประชาอุทิศ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147936	2012-06-28 15:08:48
1778	ลี้เม้งฮง บ้านบึง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147938	2013-01-04 18:49:03
1779	จิราพร ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147939	2016-07-09 17:03:16
1780	อัญชลี เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14794	2012-06-30 00:00:00
1781	สุวรรณนคร กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147941	2021-03-19 16:37:14
1782	ทวีทรัพย์ เชียงคำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147944	2012-07-05 13:29:40
1783	ไทยสวัสดิ์ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147945	2024-04-20 16:43:14
1784	รัฎวาน นราธิวาส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147947	2012-07-06 15:12:35
1785	ศิริชัย บางปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147949	2023-08-15 15:10:47
1786	จินดา นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14795	2025-01-23 12:01:22
1787	เยาวราช99 บิ๊กซี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147951	2017-01-21 20:12:57
1788	สมชัย อู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147952	2025-07-03 13:51:09
1789	โต๊ะกังรามอินทรากม7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147953	2015-08-11 14:15:36
1790	เพชรทอง อ.เยาวราช บางปะกง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147955	2012-07-22 14:10:51
1791	จินดาเยาวราช2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147956	2025-09-26 12:56:17
1792	ฝุ่งเฮงเส็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147957	2016-12-04 15:49:23
1793	ฮั้วเฮง คลอง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147958	2012-12-23 12:44:31
1794	แสงเพชร เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147961	2013-01-15 11:20:16
1795	โต๊ะกังสาย4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147962	2015-12-12 17:38:28
1796	ไทยยงดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147963	2013-07-26 16:08:44
1797	ศรีอุดม3 นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147965	2019-08-10 17:10:55
1798	บีอา1 ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147966	2025-10-03 11:45:45
1799	ศิริวัฒน์ ย. ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147967	2018-08-08 15:36:05
1800	เพชรไพลิน สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147968	2012-08-01 15:28:05
1801	รัตนมณี สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14797	2012-08-02 15:45:16
1802	โชคชัย ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147971	2023-03-15 13:17:20
1803	สำราญ บึงกาฬ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147972	2018-08-04 12:51:14
1804	โรจน์สุวรรณ สามพราน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147973	2020-04-29 10:02:47
1805	เยาวราชหลังสวน ชุมพร	0.00	0.000	0.000	1067.050	0.000	0.000	0.000	2025-11-20 15:38:54.147974	2025-10-25 15:35:13
1806	อึ้งฮะเฮง อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147977	2025-09-19 12:56:09
1807	หวังอยากมี สำนักงานใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147978	2025-10-24 11:19:44
1808	สีทองสุก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147979	2025-10-25 14:15:55
1809	ทองสวิสเยาวราช กำแพงเพชร	5613.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14798	2025-08-09 13:57:13
1810	เพชรพัฒนา เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147981	2025-10-17 10:24:31
1811	ธิปไดมอนด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147982	2025-08-06 13:22:34
1812	ศรีวารี(เจ๊ชูอินทร์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147984	2025-09-20 10:49:46
1813	เอสสุวรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147985	2016-03-17 15:40:31
1814	แม่ไข่มุก ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147987	2025-10-16 15:10:32
1815	ฝ่าเฮง ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147989	2013-10-10 15:53:01
1816	มินพิมาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14799	2018-04-07 18:34:27
1817	คุณธนเดช(พ่อ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147991	2012-08-21 11:19:33
1818	นพรัตน์ อุทัยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147994	2012-08-21 13:59:27
1819	แก้วสุวรรณ1(สาขามหาราช)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147995	2016-01-13 17:01:52
1820	เยาวราชเกตุม สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147996	2024-12-04 16:21:57
1821	ศรีกาญจน์ กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147997	2025-10-18 14:08:55
1822	ช่างเปี๊ยก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147998	2016-09-30 21:34:40
1823	บีอา2ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.147999	2025-09-13 16:58:52
1824	เพชรแก้วภูเก็ต ๒	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148001	2017-03-15 16:46:00
1825	ไทยมิตร คลองครุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148002	2015-11-09 11:32:27
1826	จินเซ่งเฮง สำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148003	2025-07-17 12:42:00
1827	แก้วมณีปากน้ำสาขา(เพื่อน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148004	2012-09-04 15:00:54
1828	แสงทองใบจันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148005	2021-06-18 10:39:58
1829	แก้วสุวรรณ1 (แม่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148007	2012-09-28 16:36:58
1830	วิเชียร บางปะอิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148009	2013-04-04 16:21:40
1831	ช่างสุภาภรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14801	2016-10-10 14:30:41
1832	เยาวราชงามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148012	2020-01-07 13:40:23
1833	เยาวราชบ้านแท่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148013	2024-08-08 16:35:58
1834	บีอา ตะกั่วป่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148014	2025-09-27 15:16:13
1835	อุษณี21	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148015	2012-09-13 16:29:16
1836	น่ำเกียเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148016	2012-09-11 17:06:25
1837	รุ้งเจริญ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148017	2025-10-15 12:57:55
1838	คุณโหน่ง MC	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148019	2013-02-14 17:12:39
1839	วอชิงตัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14802	2016-03-06 11:46:47
1840	แม่กิ่งทอง บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148021	2015-11-13 16:46:45
1841	เพชรไชยา สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148022	2014-08-14 14:07:53
1842	ทองใบ1นครสวรรค์ 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148024	2013-01-26 09:45:17
1843	ดีจริงเยาวราช วาปี	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.148025	2025-10-22 12:40:46
1844	เยาวราชเอก วัดไพร่ฟ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148026	2019-11-30 09:56:58
1845	เยาวราชเอก 4มุมเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148028	2018-06-20 16:13:10
1846	เยาวราชเอก ตลาดไท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148029	2016-09-22 10:36:18
1847	เยาวราชเอก โลตัสคลอง7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148032	2016-09-22 10:42:09
1848	เทพพิทักษ์1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148033	2012-10-12 17:35:03
1849	ศรีรัตน์ ปราจีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148034	2020-01-03 09:55:13
1850	คุณวิชิต22	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148036	2012-10-17 09:52:22
1851	ช่างปรางค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148037	2016-11-08 12:24:47
1852	รุ่งโรจน์ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148038	2025-08-08 15:25:34
1853	ดำรงชัยกิ่งแก้ว2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148039	2013-03-20 10:04:35
1854	ลี่จิ้นไถ่ สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148041	2025-09-24 14:51:33
1855	พัฒนา ตราช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148042	2025-04-18 12:53:24
1856	ศรีทอง เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148043	2025-10-25 10:28:35
1857	ก๊วยเฮง(บุญชู)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148044	2013-02-05 17:04:51
1858	รุ่งทรัพย์ พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148045	2015-11-13 16:42:43
1859	ฉายากุล สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148047	2023-10-14 14:11:36
1860	มหาชัยอุบล2(ลูกสาวเต็กเซ่งฮวด)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148048	2013-02-17 17:22:50
1861	โชคชัยน่าน สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148049	2016-06-26 11:14:00
1862	มังกรทอง ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14805	2019-11-06 09:06:21
1863	แม่กิ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148051	2012-10-04 15:00:18
1864	แม่กิ่งทอง มหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148052	2016-09-30 14:26:56
1865	มังก5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148053	2012-10-06 10:42:33
1866	ภูธนัญ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148056	2020-09-25 15:30:55
1867	คุณแจงMC	0.00	0.000	0.000	2134.200	0.000	0.000	0.000	2025-11-20 15:38:54.148057	2025-10-01 15:21:52
1868	โชกุน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148058	2012-10-12 13:33:24
1869	เล่ากี่เส็ง นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148059	2025-10-25 12:46:41
1870	สุวรรณศิลป์ลาดกระบัง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14806	2018-11-14 16:56:44
1871	ยิ่งเจริญบางพลี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148061	2013-02-19 13:49:38
1872	คุณวี(คุณทัศนีย์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148063	2012-10-17 17:39:59
1873	เยาวราชเอก รังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148064	2012-10-19 09:27:44
1874	เชียงรายนพคุณ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148065	2016-11-30 10:56:18
1875	หวังสินไทย2 (2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148066	2025-02-14 08:38:30
1876	ทองกรุงเทพศรีสะเกษ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148067	2013-05-26 10:57:34
1877	แม่จันทรา เชียงแสน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148068	2018-04-21 16:22:55
1878	เยาวราชโพทะเล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14807	2021-09-19 14:21:32
1879	กนิษฐาตลาด304	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148073	2012-12-11 11:34:57
1880	ศรีบุญญา กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148074	2012-11-07 17:12:55
1881	สมใจ1 นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148075	2018-05-17 17:20:04
1882	มงคลทรัพย์ พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148076	2019-12-18 17:13:18
1883	สุมารัตน์ VS	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148077	2025-08-01 10:06:13
1884	จินดา ประตูน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148078	2018-12-25 17:18:24
1885	เยาวราชเฮงเฮง สะพานแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148079	2023-04-07 09:49:12
1886	สุวรรณหงษ์ สำเหร่	571.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14808	2014-05-16 00:00:00
1887	สมใจ14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148081	2018-08-31 16:31:34
1888	ฉายากุล2 สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148082	2012-11-07 10:05:33
1889	เยาวราชกรุงเทพ พุทไชสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148083	2012-11-03 11:57:31
1890	รัตนสุวรรณ5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148084	2024-10-16 09:34:32
1891	ทวีโชค พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148087	2018-05-27 13:50:00
1892	เยาวราชบางมุลนาก พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148088	2018-06-05 16:13:49
1893	หงี่ขุนเส็ง ประเวศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148089	2016-02-11 13:53:32
1894	นำโชค1997 บางกระดี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14809	2020-07-31 17:40:20
1895	ปาลิกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148091	2020-12-03 15:21:34
1896	เที่ยงธรรม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148092	2025-06-27 16:15:46
1897	จิตรลดา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148093	2023-03-29 16:29:18
1898	หงส์คูฟ้า พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148094	2024-05-28 11:45:09
1899	เมืองพลอย สกล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148095	2021-03-13 16:55:00
1900	เยาวราชชากค้อ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148096	2013-03-26 12:04:00
1901	ลินดา ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148097	2016-09-22 13:31:44
1902	เจริญทวี ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148098	2015-10-24 15:34:31
1903	สินสมบูรณ์ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148101	2024-12-17 16:25:47
1904	ลิ้มป๋อไล้ สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148102	2016-03-16 16:43:26
1905	ไทยยินดี พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148103	2016-01-21 10:24:02
1906	จิตสุดา เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148104	2025-08-26 15:38:09
1907	จิตรา สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148105	2012-11-17 13:52:45
1908	ทองธรรศ์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148106	2013-09-25 00:00:00
1909	เยาวราชหนึ่งบางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148107	2024-11-02 13:22:27
1910	แม่สมจิตร แหลมสิงห์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148108	2025-01-26 09:38:00
1911	มณีรัตน์ โพทะเล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148111	2018-07-01 12:12:38
1912	วัฒนา มหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148112	2019-04-04 18:09:11
1913	แม่ซิวเฮียง ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148112	2023-02-22 15:47:44
1914	กนกรัชต์ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148113	2024-06-19 13:40:10
1915	เยาวราช999ราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148116	2014-05-08 15:12:57
1916	คุณต้น(ช่างโต)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148117	2013-01-08 13:53:35
1917	เจริญผล ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148118	2014-11-16 16:24:11
1918	ช่างเจี๊ยบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148119	2012-12-04 19:08:26
1919	เพชรยินดี กระทุ่มแบน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14812	2022-09-29 15:58:28
1920	จงเซ่งเฮง ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148121	2016-09-30 16:36:02
1921	แสงอาทิตย์ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148122	2025-08-13 14:27:39
1922	เพชรรัตน์1 ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148123	2012-12-02 13:47:36
1923	ฮั่งเชียงเฮง เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148124	2017-11-07 10:25:53
1924	แม่ทองบาง5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148125	2013-08-06 09:47:19
1925	ช่างเซี๊ยะจั๊ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148126	2020-02-23 10:17:56
1926	แม่สวัสดิ์ ห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148127	2024-09-06 15:19:22
1927	พงศ์สวัสดิ์ บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148129	2013-06-13 17:06:42
1928	เยาวราชบางเสาธง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14813	2023-10-21 11:22:35
1929	ทองกรุงเทพ พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148131	2013-08-18 11:37:11
1930	คุณดารา(วาสนา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148132	2012-12-11 12:50:45
1931	แสงทองใบ วิชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148133	2016-06-26 13:44:23
1932	เหรียญทอง3 บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148136	2024-10-27 12:57:40
1933	เดือนเพ็ญ หนองชาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148137	2019-03-13 11:13:02
1934	กนกภัณฑ์ วังน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148138	2014-03-05 16:34:52
1935	ตั้งเซียมเฮง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148138	2024-04-24 10:56:56
1936	เจ๊เอ็งเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148139	2025-05-02 13:43:55
1937	เยาวราชบางโฉลง บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14814	2012-12-13 15:17:49
1938	เยาวราช(ตราม้งกร) กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148141	2013-01-10 16:21:44
1939	โต๊ะซิ้วฮง แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148144	2015-12-15 13:18:30
1940	กอบกิจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148145	2018-03-27 16:23:55
1941	ทองจิตรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148145	2013-04-25 15:02:02
1942	ผ้างพานิช กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14815	2025-07-10 15:17:34
1943	เอราวัณ หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148151	2022-12-20 18:12:13
1944	ยิ่งเฮง ตลาดพลู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148152	2017-07-04 12:29:11
1945	จูทองดี เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148153	2022-01-09 15:10:56
1946	รัตนไพจิต นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148155	2025-05-14 10:43:48
1947	เหรียญทอง เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148156	2025-10-24 14:37:19
1948	เยาวราชแปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148157	2022-01-08 14:43:32
1949	อุษณีย์22	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148158	2012-12-20 15:42:32
1950	อุษณีย์23	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148159	2013-01-17 14:25:39
1951	หทัยภัทร อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148161	2015-03-26 17:04:10
1952	กิมเล่งเฮง9	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148162	2015-05-26 00:00:00
1953	นาทีทอง (พะเยา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148163	2013-03-23 11:05:14
1954	อุษณีย์24	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148164	2012-12-25 11:29:49
1955	อุษณีย์25	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148165	2013-01-04 09:58:17
1956	อุษณีย์26	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148166	2013-01-17 14:24:44
1957	คุณปุ่น	0.00	0.000	0.000	457.300	0.000	0.000	0.000	2025-11-20 15:38:54.148167	2012-12-22 17:17:27
1958	รุ่งนภา (จิต)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148168	2013-01-04 09:36:44
1959	จารุพันธ์ แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148169	2012-12-23 14:10:45
1960	กิมเล่งเฮง5โต๊ะกัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14817	2015-07-05 13:44:05
1961	ชัยเจริญ ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148172	2016-09-10 15:50:50
1962	ศรีทองสุข นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148173	2013-09-09 17:18:56
1963	เยาวราช999 ศาลายา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148176	2013-02-13 13:09:13
1964	ซิงเฮงหลี ลำปาง	0.00	706.050	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148177	2025-10-24 09:47:04
1965	เยาวราชศิขรภูมิ3	-2624932.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148178	2018-04-18 11:29:38
1966	ซุนเฮง ป้อมพระจุล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148179	2016-01-08 11:30:39
1967	แสงทองใบ สี่มุมเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148181	2014-01-24 17:34:05
1968	กิจสุวรรณ(พญาเม็งราย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148182	2021-02-27 16:48:22
1969	มณีภัณฑ์ สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148183	2017-03-11 15:21:20
1970	คุณสุภาพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148184	2019-12-15 15:03:21
1971	จีระนันท์ พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148185	2020-09-09 15:15:26
1972	ชัยสวัสดิ์ ดินแดน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148186	2013-03-24 09:48:27
1973	แจ่มฟ้า ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148187	2016-07-23 08:59:20
1974	เยาวราช กุฉินารายณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14819	2015-09-01 15:38:57
1975	ศรีสมบูรณ์(นิด)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148192	2025-09-28 14:24:00
1976	พรสุพรรณโลตัสศรีนคริทร์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148194	2013-01-14 14:11:09
1977	ทองยงดี สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148195	2019-03-20 17:23:29
1978	พรสุพรรณโลตัสพัฒนาการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148196	2016-09-29 12:10:10
1979	พนักงานบิ๊ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148197	2013-01-17 17:00:20
1980	คุณธงชัย825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148198	2024-04-23 09:22:19
1981	กมลรัตน์825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148199	2022-03-09 14:42:37
1982	พรเจริญ มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148201	2020-09-17 16:03:41
1983	แม่อิมเฮง ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148202	2016-02-21 12:02:35
1984	แม่อิมเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148203	2013-01-18 16:16:18
1985	อี้งเซ่งเฮง พระสมุทรเจดีย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148204	2013-01-19 10:44:06
1986	เพชรทองเยาวราช บางกรวย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148205	2016-12-09 11:06:09
1987	เสือมังกร เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148207	2025-10-03 11:34:05
1988	ทรรศนีย์ เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148208	2025-02-02 15:34:34
1989	อ้อยทองดี บางมูลนาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148209	2016-02-28 13:02:35
1990	แม่อิ่ม5 กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14821	2013-09-04 17:07:49
1991	แสงมณี สุรินทร์	0.00	0.000	0.000	914.650	0.000	0.000	0.000	2025-11-20 15:38:54.148211	2025-10-17 08:46:10
1992	วัชรินทร์ นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148213	2013-01-23 17:55:08
1993	โชควิวัฒน์1 อุตรดิตถ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148214	2019-05-29 17:55:32
1994	แม่ไพจิตร นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148215	2025-05-16 12:57:08
1995	ต.ศรีทองเยาวราช อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148216	2017-04-01 18:08:58
1996	ต.ศรีทองเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148217	2013-01-25 16:13:18
1997	วิธาน ปราจีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148218	2019-07-27 11:55:55
1998	พงษ์ทองดี5 กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148219	2013-01-27 11:14:36
1999	เจริญทวี มานพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148221	2016-04-24 11:30:39
2000	เจริญทวี เทอดพันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148222	2020-06-14 14:28:13
2001	เจริญศรี เทอดพันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148223	2013-01-27 14:40:10
2002	ทองดีเยาวราช เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148224	2018-09-15 10:44:31
2003	กมลพรรณ ปัตตานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148225	2022-06-11 16:09:41
2004	เยาวราชสิเกา ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148226	2020-07-25 15:13:27
2005	หยกแก้ว พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148227	2019-09-28 15:58:03
2006	เรืองอนันต์อุบล	-110.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14823	2013-03-26 14:16:03
2007	ธนะพัฒน์ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148231	2018-11-04 10:57:45
2008	อุ่ยอุทัย เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148232	2023-10-28 14:26:54
2009	เยาวราชยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148232	2015-04-26 14:42:25
2010	พงษ์ทองดี19	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148233	2025-08-21 13:08:05
2011	เยาวราชปาดังเบซาร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148236	2013-02-02 14:49:25
2012	แม่ทองใบ ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148237	2019-07-31 15:28:28
2013	ทองสยาม ปราจีน1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148238	2014-10-31 16:04:05
2014	ทองสยาม ปราจีน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148239	2015-10-17 12:52:01
2015	จูลี่(เยาวราช) พระประแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14824	2020-11-25 14:37:22
2016	เกียว2 นครชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148241	2014-11-10 17:28:14
2017	แม่บุญมา มีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148244	2022-03-18 09:25:13
2018	พนักงานปาล์ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148245	2023-06-01 10:40:41
2019	แม่ทองคำ2เยาวราช นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148246	2024-01-09 17:14:50
2020	ติ๊กหญิง(พนักงาน)	10070.00	0.000	0.000	152.350	0.000	0.000	0.000	2025-11-20 15:38:54.148246	2025-10-24 09:18:19
2021	รุ่งนภาเจมส์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148247	2025-10-21 11:07:03
2022	เยาวราชโคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148249	2013-02-13 18:42:39
2023	สายสมร(เดมอนด์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148251	2025-03-27 11:33:47
2024	เยาวราช อิมพีเรียล สำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148252	2013-02-14 10:05:17
2025	เบญจวรรณ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148253	2013-02-14 15:14:22
2026	ทองประเสริฐ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148254	2013-02-14 15:08:23
2027	รักไทย2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148255	2018-06-14 13:23:44
2028	รักไทย2 สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148256	2014-11-21 13:42:21
2029	น่ำเฮงล้ง ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148257	2025-06-07 13:47:16
2030	แม่กลอง1(ฮวดหลี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148258	2013-02-17 13:38:38
2031	นำเจริญ มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148259	2013-06-21 12:58:41
2032	คูณทรัพย์ บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148259	2013-02-19 12:25:15
2033	แม่สมบัติ พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14826	2014-03-12 14:57:35
2035	วสุพร พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148262	2018-01-20 17:15:57
2036	ศรีมงคล มีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148265	2013-10-09 15:18:42
2037	ตั้งคุงฮะ นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148266	2025-08-31 14:18:43
2038	คุณทวีศักดิ์14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148269	2025-10-02 13:43:08
2039	อุษณี28	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14827	2013-02-26 14:39:57
2040	อุษณี29	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148271	2013-02-22 13:16:12
2041	อุษณี30	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148272	2013-04-23 13:19:56
2042	อุษณี31	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148273	2013-02-22 13:16:53
2043	อุษณี32	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148273	2013-02-22 13:17:12
2044	กรุงเทพเสือคู่ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148274	2015-11-07 10:30:57
2045	สุมาลี ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148275	2025-09-24 10:44:07
2046	ศศิธร ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148276	2015-10-10 14:46:25
2047	นภารัตน์ สตูล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148277	2013-05-21 17:02:44
2048	ทองสำเริง ชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14828	2013-02-24 12:11:54
2049	แสงทอง2 ปากเกร็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148281	2024-05-08 08:45:31
2050	อยากมีตัง นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148282	2016-10-07 11:37:08
2051	เจริญพร รังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148283	2025-10-10 14:32:15
2052	แสงทอง2 แม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148284	2019-07-05 15:17:09
2053	คุณจิ๊บ หลาน	0.00	0.000	0.000	457.300	0.000	0.000	0.000	2025-11-20 15:38:54.148285	2020-12-11 15:32:11
2054	พรอนันต์ โลตัสอมตะนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148286	2013-03-29 11:51:22
2055	เอ็งฮั้ว สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148287	2019-06-21 16:27:03
2056	เยาวราชลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148288	2013-02-27 12:06:14
2057	ศรีสมบูรณ์ พระประแดง  	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148288	2013-05-09 16:40:20
2058	กิจเจริญ304ศรีมหาโพธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148289	2018-04-07 18:19:56
2059	แม่บุญมา หนองจอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14829	2017-02-13 14:04:25
2060	คุณกนกวรรณ(สุวรรณกาญจน์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148293	2013-06-06 11:03:23
2061	อภิชาติ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148294	2016-06-11 13:14:28
2062	ทองวิเศษ สุพรรณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148356	2013-03-02 16:50:50
2063	แม่สมบูรณ์งามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148357	2013-07-16 16:30:35
2064	คุณจิ๋ม หลาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148358	2022-04-27 13:00:06
2065	เสริมสุวรรณ มีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148359	2017-04-07 17:00:03
2066	ชัยสุวรรณ ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14836	2013-03-07 15:42:35
2067	เก้ามังกร ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148361	2020-03-07 17:57:45
2068	จินไถ่4 เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148362	2014-02-09 12:28:36
2069	เพชรทองเยาวราชสระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148364	2022-08-02 16:39:21
2070	เยาวราชสมอทอด เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148365	2013-03-09 09:37:39
2071	นวพร พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148366	2020-08-07 08:57:53
2072	โชคดี สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148369	2025-03-02 13:18:46
2073	จันทร์เพ็ญ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14837	2013-03-21 15:57:11
2074	เพชรทองถุ่งฟุง แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148371	2015-12-19 16:17:24
2075	กิมฮั้วเฮง พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148372	2022-01-08 16:11:48
2076	คุณหมู หลาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148373	2013-03-19 14:08:46
2077	น้อมจิตต์เยาวราช บางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148374	2014-07-18 13:19:56
2078	ลี้จิ้นไถ่ ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148375	2015-05-13 14:32:47
2079	เป้งม้งเฮง สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148377	2021-04-08 10:14:30
2080	ช.มากผล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148378	2021-11-10 16:50:20
2081	ตั้งลิ้มเฮง เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148379	2013-05-13 13:17:46
2082	ทองคำเก้าบางใหญ่ซิตี็ นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14838	2013-03-15 16:43:06
2083	เดอะเบสท์ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148381	2025-10-22 18:27:01
2084	ยิ่งเจริญ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148383	2019-06-11 14:51:54
2085	พลอยสยาม(โจ้)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148385	2025-10-18 09:29:30
2086	รักไทย1 สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148386	2018-01-13 15:19:30
2087	ตังย่งหลี สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148386	2013-03-21 18:23:44
2088	เยาวราชอ้อมน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148387	2019-01-25 15:54:33
2089	ศรีรุ่งเรือง พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148389	2025-10-24 17:21:59
2090	ทวีชัย โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14839	2025-09-09 12:59:42
2091	คุณเซ็ง (กุ๊ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148391	2019-03-26 15:37:06
2092	เบ็ฮั่วแซ อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148392	2013-03-28 12:51:35
2093	เหรียญทองดี นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148394	2024-12-06 12:02:21
2094	เจริญทรัพย์ อ.พาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148395	2013-06-19 14:39:53
2095	วังสิริเยาวราช โพธาราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148396	2013-03-30 12:02:10
2096	เมืองทอง กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148398	2014-12-16 17:38:44
2097	จงเจริญเยาวราช กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148399	2025-09-30 16:25:56
2098	ชัยชนะ ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1484	2019-04-27 19:05:09
2099	เซ่งเฮงล้ง ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148401	2022-11-10 17:09:37
2100	พรทวี บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148402	2018-07-11 14:58:08
2101	เมืองทองเยาวราช ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148405	2022-12-08 14:56:34
2102	แม่เง็ก2 ชูชัย มหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148406	2016-06-30 15:30:46
2103	เยาวราชปากช่อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148408	2017-01-20 17:23:13
2104	นกยูงทอง ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148409	2025-10-24 15:28:26
2105	ทองเกษตร ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148411	2024-03-26 17:01:10
2106	เรือนเพชร สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148412	2014-12-18 10:42:33
2107	คุณพรสวรรศ์ (พี่ยอด)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148413	2013-04-05 21:24:10
2108	ทองถม พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148416	2023-07-07 15:30:44
2109	ทองไพบูลย์ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148417	2025-10-22 17:48:18
2110	คุณแท็ก (ญาติมิกส์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148418	2013-04-11 11:04:43
2111	โต๊ะกังวังม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148419	2023-05-07 12:36:24
2112	เอี๋ยงเซ่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14842	2016-05-22 14:14:44
2113	คุณจา รัดสาด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148421	2017-01-17 18:52:15
2114	อันดับ1 สำนักงานใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148422	2024-03-21 15:52:37
2115	ตั้งเชียงเฮง ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148423	2013-04-19 17:00:23
2116	กรุงเทพ สุไหงโกลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148424	2023-07-06 16:23:31
2117	คุณสมศรี เลขาคุณกานดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148425	2013-09-03 14:23:26
2118	จินไถ่1 เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148426	2013-09-13 13:41:05
2119	กรชัย สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148428	2019-01-10 17:30:11
2120	เยาวราชคลองหาด สระแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14843	2018-03-25 12:42:30
2121	เยาวราชกะรัต สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148431	2021-04-06 18:13:37
2122	เยาวราชวีไอพี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148432	2024-11-20 15:53:36
2123	โต๊ะกังท่าม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148433	2015-12-02 15:07:27
2124	ธนบุรีทองคำ 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148435	2013-11-05 09:34:38
2125	เยาวราชแม่ศรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148436	2013-05-23 16:01:40
2126	เต็งพานิช หล่มสัก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148437	2013-04-25 19:07:39
2127	อรวรรณ อุทัยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148438	2014-01-04 17:49:18
2128	หวังสินไทย ใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14844	2024-06-26 16:06:51
2129	มังกรทอง พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148441	2023-11-25 15:25:53
2130	ธงชัยดอนสัก สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148442	2015-01-29 13:43:36
2131	ธงชัยขนอม นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148443	2017-03-13 15:02:32
2132	แม่จันทร์เพ็ญ(รวมโชค) 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148445	2024-10-26 09:31:38
2133	แม่อำนวย ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148448	2013-04-28 13:40:56
2134	ทองดี สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148449	2013-05-02 10:44:45
2135	จิวเจริญดี กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14845	2025-10-26 11:16:30
2136	เยาวราชบ้านโพธิ์ ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148451	2013-05-02 17:01:20
2137	เหรียญทอง เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148452	2025-05-07 10:05:47
2138	วัชรพล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148453	2013-05-04 13:59:00
2139	คุณวิเชียร(กุ๊ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148455	2014-03-07 14:41:44
2140	ปอมปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148456	2017-03-31 12:49:47
2141	ตั้งธนสิน ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148457	2013-05-09 12:08:28
2142	ไทยนคร นครพนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148458	2013-05-10 10:31:23
2143	เยาวราชเชียงของ เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148459	2013-05-10 10:57:11
2144	วิวัฒน์กิจ บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148462	2013-05-10 15:13:16
2145	เหรียญชัย นราธิวาส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148464	2022-08-02 13:44:32
2146	รัตนากร บางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148465	2025-10-07 11:24:09
2147	แสงเพชร บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148466	2019-11-29 17:31:09
2148	ถุ่งฟุง สำนักงานใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148467	2013-09-22 13:50:32
2149	อธิชาติ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148469	2021-07-11 13:06:30
2150	อภิชาติ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14847	2013-05-17 10:56:26
2151	ธนู อารีย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148472	2013-05-17 17:12:13
2152	บิ๊กซี ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148473	2020-08-07 09:18:22
2153	ภาณุ (คุณหมีเพื่อนปลา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148474	2016-06-09 10:09:58
2154	น้องสุมาลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148475	2014-09-25 15:41:01
2155	เอกธนภัทร หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148477	2013-05-22 11:13:46
2156	100% พนมสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148479	2024-09-27 15:50:49
2157	เพชรทองคำ ปราจีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14848	2017-06-28 15:47:33
2158	มิตรใหม่ จอมพระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148481	2025-08-21 14:27:58
2159	ย่งฮวดเฮง พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148483	2014-10-05 09:10:01
2160	ปิ่นทองใบ บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148484	2013-06-01 11:51:48
2161	แต้เฮงเฮง ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148485	2023-09-07 14:14:39
2162	อากิม แก้วคร้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148486	2025-03-05 10:46:42
2163	ลักกี้ หนองจอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148487	2016-11-24 16:00:15
2164	กัญญา สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148488	2013-05-30 14:51:53
2165	บุญเฮง กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148491	2017-07-01 13:10:18
2166	ธีระภัณฑ์9 อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148492	2021-02-10 10:29:04
2167	ทองแท้เยาวราช นิคมพัฒนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148493	2013-06-16 13:08:49
2168	เสือมังกรเชียงใหม่2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148496	2022-10-09 08:55:09
2169	แม่พรรณี หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148497	2013-07-05 17:27:04
2170	จินดา เบตง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148499	2022-12-14 15:28:49
2171	วัชระ สมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1485	2025-06-03 14:29:40
2172	แม่มะลิ สุขุมวิท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1485	2025-09-23 15:37:10
2173	เจนถิ่น แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148502	2015-03-10 17:47:51
2174	แต้ฮุยล้ง2 ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148503	2025-09-03 08:50:54
2175	สิริจันทร์ ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148504	2013-09-13 15:27:41
2176	ห้างทองเยาวราชบางพลี(เจ๊นิจ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148505	2022-12-15 13:00:51
2177	อุษณี33	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148506	2013-06-25 13:08:53
2178	อุษณี34	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148507	2013-06-25 13:21:30
2179	อุษณี35	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148508	2013-06-28 14:14:39
2180	อุษณี36	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148509	2013-06-28 18:54:00
2181	อุษณี37	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148511	2013-06-21 14:00:12
2182	อุษณี38	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148512	2013-10-29 17:13:49
2183	อุษณี39	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148513	2013-10-29 12:24:49
2184	อุษณี40	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148514	2014-01-14 12:19:51
2185	แม่ทองหล่อ สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148515	2018-03-30 14:46:11
2186	คุณตุ๊ก(แอร์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148516	2013-08-13 16:26:31
2187	ทองดีเยาวราช กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148518	2015-04-26 13:05:57
2188	เคี่ยงเฮงล้ง นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148519	2013-06-23 11:22:17
2189	เหรียญทอง1 บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14852	2019-10-06 12:48:44
2190	ซิน2 บ่อวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148521	2016-09-27 10:41:48
2191	คุณแป๊ะYJH(เพื่อนคุณชูวิทย์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148522	2018-08-16 10:35:21
2192	เอราวัณช้างเผือก เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148523	2013-06-25 12:37:58
2193	เยาวราชดีดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148528	2021-02-18 16:37:17
2194	ทรัพย์มงคล อ่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148529	2025-09-03 14:33:17
2195	โอ๋ พนักงาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14853	2016-04-20 13:59:31
2196	เจริญทวี ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148532	2025-09-12 14:49:51
2197	เคี้ยงเซ่งเฮงเยาวราช 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148534	2014-03-22 11:36:20
2198	ดำรงค์ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148535	2025-09-05 10:23:59
2199	คุณตา MC	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148536	2025-04-09 10:47:59
2201	เยาวราช(หลานแม่กิมกี่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148539	2016-04-29 16:17:03
2202	แจ่มฟ้าลำพูน2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14854	2013-07-09 14:40:03
2203	ฉัตรทอง บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148541	2019-01-20 15:38:52
2204	เยาวราชรังสิต อพาร์ทเมนต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148542	2017-07-26 17:53:21
2205	จิ่งหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148545	2018-12-21 12:24:25
2206	คุณแม่บี๊	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148546	2025-03-22 11:55:04
2207	เอกอนันต์เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148547	2014-08-05 17:11:47
2208	ถาวรพานิช ฝาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148548	2017-03-22 13:27:37
2209	อุมารินทร์ กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148549	2013-07-12 17:02:10
2210	ปลามังกร อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14855	2013-07-13 14:52:05
2211	เพชรทวี ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148551	2013-07-15 14:11:41
2212	ป.อุดมสุข สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148553	2020-05-05 08:49:37
2213	แม่กี นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148554	2013-10-09 16:37:23
2214	เยาวราชรังสิต(เฮียอ้วน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148555	2013-07-19 13:39:09
2215	ทองธเนศ ตลาดสด	0.00	141.250	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148556	2025-10-08 10:29:23
2216	เฮงเฮงเยาวราช หล่มสัก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148557	2025-02-06 16:15:35
2217	ขวัญทอง กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148559	2025-08-14 09:42:57
2218	เม้งเยาวราช ห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148561	2023-08-10 16:08:36
2219	จิบเฮง พัฒนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148562	2025-06-18 11:06:47
2220	สวิสเยาวราชบ้านผือ อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148563	2014-04-06 13:43:54
2221	สมบูรณ์พานิช เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148564	2023-06-07 15:33:42
2222	เยาวราชบ้านบ่อ สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148565	2019-05-22 17:02:18
2223	บุญศิริ กาฬสินธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148566	2013-08-08 17:55:17
2224	ทิพย์ สวนมะลิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148567	2014-02-12 15:29:56
2225	จินตนา ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148568	2014-11-19 10:09:42
2226	แหลมทอง สุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148569	2014-06-07 16:27:37
2227	ชัยพัฒนา นวนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148571	2018-06-24 14:44:01
2228	พัฒนาหนองไผ่ แม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148573	2025-05-20 11:42:56
2229	ไทยเจริญ ฝาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148575	2016-05-28 12:45:37
2230	ยิ่งเจริญ สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148576	2023-08-31 15:46:46
2231	คำทิพย์ (พี่จิ๋ม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148578	2019-07-18 10:44:01
2232	อัศวิน ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148579	2022-11-03 16:17:27
2233	ศิริรุ่งแสง ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14858	2016-01-12 15:03:49
2234	ทองสวยเยาวราช สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148581	2023-03-17 09:27:37
2235	ชัยอนันต์ สตูล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148582	2021-11-24 13:26:29
2236	ไทยเจริญ ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148583	2013-09-01 16:24:18
2237	นำเจริญ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148585	2019-10-09 10:12:37
2238	เจริญสุขเยาวราช พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148586	2017-11-29 16:17:22
2239	วงศ์ทรัพย์9	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148587	2022-03-06 16:27:22
2240	ช่างวัชรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148588	2024-04-09 12:26:20
2241	ตั้งกวงเชียง อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14859	2016-09-28 11:26:14
2242	เยาวราชคลองตัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148591	2025-02-16 10:10:06
2243	คุณษูMC	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148592	2020-08-11 12:10:24
2244	บุญวิชิต สุราษฎร์ธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148593	2014-06-24 16:23:29
2245	ท่านอำพน เจริญชีวินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148594	2018-11-16 12:30:15
2246	ช่างสมเกียรติ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148595	2019-05-18 11:30:54
2247	เพชรทองดี เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148596	2013-09-28 16:48:57
2248	เยาวราช คลอง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148597	2017-09-24 10:16:28
2249	พัชระ พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148599	2015-07-09 15:52:22
2250	ไทยย่งเต็ง ตันหยงมัส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1486	2015-06-27 15:12:35
2251	บีอา 3 ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148601	2025-01-19 14:56:44
2252	ช่างณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148602	2025-10-16 10:43:03
2253	ท่านสมยศ วัฒนภิรมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148604	2016-04-26 15:02:59
2254	คุณหน่อยmc	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148605	2024-05-09 14:52:45
2255	คุณเชน ชั้งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148606	2016-10-21 10:41:35
2256	เอกมณี บางหว้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148607	2014-07-20 09:28:55
2257	แม่มะลิ2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148608	2013-10-27 14:12:19
2258	พราวพลิน แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148609	2016-09-22 10:00:19
2259	เบญจวรรณ เตาปูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14861	2013-10-12 16:37:21
2260	ก๊วยเซ่งเฮง รังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148613	2016-03-26 16:12:35
2261	แม่ทองหล่อ จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148614	2022-07-07 14:52:14
2262	ลิ้มเคียนฮวด2 กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148615	2014-03-11 00:00:00
2263	ทองใบ9 ทุ่งครุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148616	2013-12-03 15:15:41
2264	หมุยฮะ(ลัดดา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148618	2013-10-18 12:55:48
2265	พุดเซ่งเฮง สวนพลู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14862	2013-10-22 17:49:07
2266	เม็งเซ่งเฮง สวนหลวง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148621	2013-10-23 14:02:59
2267	เฮียแป๊ะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148623	2018-12-26 11:27:47
2268	ต่วนกี่(ละงู)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148624	2013-12-19 16:32:43
2269	ทองปลาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148625	2016-09-27 15:17:28
2270	คุ้มทิพย์ เซ็นทรัลบางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148626	2014-01-28 13:38:33
2271	โชคทองดี (หนองจอก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148627	2018-07-18 17:11:18
2272	ทองสุพรรณ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148629	2018-02-13 15:06:12
2273	100%โพธิ์ทอง อ่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148631	2013-11-05 15:01:28
2274	เยาวราช I D Gold เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148632	2016-04-03 11:28:59
2275	แสงชัย เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148633	2019-11-01 16:52:46
2276	เฮียเซ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148634	2021-03-04 17:41:57
2277	ฉัตรแก้ว สุทธิสาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148637	2015-12-13 15:54:32
2278	ทองนคร สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148638	2019-01-19 11:24:30
2279	ศรีวิชัย ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148639	2024-09-12 11:36:09
2280	ก้องฟ้าเยาวราช(กิมเต็ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14864	2014-05-08 12:58:11
2281	เจริญ ปากเกร็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148642	2014-07-25 12:05:28
2282	อุษณี41	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148643	2013-12-04 09:32:19
2283	อุษณี42	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148644	2014-04-02 11:22:21
2284	อุษณี43	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148645	2013-12-03 21:37:11
2285	อุษณี44	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148646	2013-12-03 21:37:21
2286	อุษณี45	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148647	2014-08-22 15:18:17
2287	อุษณี46	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148647	2014-06-01 11:39:23
2288	ทองดีเยี่ยม ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148648	2014-03-15 12:18:03
2289	ทองพันชั่ง บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148651	2014-09-02 13:19:45
2290	กันเอง 2 ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148652	2025-06-24 12:11:14
2291	คุณตุ๊ก (รัตน์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148653	2016-01-27 09:09:30
2292	แม่ยุพิน พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148655	2014-01-09 13:05:09
2293	ช.ชัยณรงค์ ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148657	2015-03-05 15:06:23
2294	PY จิวเวอรี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148657	2017-07-11 14:31:58
2295	ทองไทยโลตัส ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148659	2014-06-03 16:09:15
2296	ทองพันชั่ง บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14866	2014-06-24 11:59:41
2297	ทองพันชั่ง สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148661	2015-10-10 14:01:15
2298	เยาวราชบิ๊กซี อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148661	2019-08-09 17:23:47
2299	ฮงเซ่งเฮง อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148662	2024-07-14 12:18:04
2300	ตั๊กเซ่งฮง,ตั๊กเซ่งล้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148663	2014-11-20 14:51:48
2301	เกียวเยาวราช3 อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148666	2014-11-04 17:18:25
2302	ทองดีเยาวราช พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148667	2015-03-21 13:51:20
2303	เยาวราชนาวง ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148668	2020-08-28 16:04:28
2304	แม่สายใจ2 ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148669	2025-09-25 15:45:28
2305	หงษ์ทอง ห้วยปราบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14867	2013-12-28 14:07:17
2306	สี่ฮัั่วหลี ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148671	2014-02-06 17:18:51
2307	ไทยนิรันดร์ บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148672	2014-04-29 14:11:01
2308	เยาวราชกิมอู๋ บุรีรัมย์	2000.00	0.000	0.000	76.250	0.000	0.000	0.000	2025-11-20 15:38:54.148673	2025-09-05 16:07:33
2309	สุวรรณภูมิ แปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148674	2015-12-10 16:08:07
2310	เยาวราชเสรี สามพราน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148675	2014-01-17 16:39:09
2311	สีฟ้า2 แกลง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148676	2025-10-25 14:56:53
2312	เยาวราชสุขสันต์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148678	2017-04-08 14:58:40
2313	สุวรรณา สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14868	2024-07-14 13:21:52
2314	สุวรรณา สาขา4 มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148681	2014-01-09 10:51:29
2315	สุวรรณา สาขา2 มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148682	2014-12-24 13:03:11
2316	สมใจ หลังสวน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148683	2023-05-04 09:08:17
2317	ธำรงค์ศักดิ์ แพร่	0.00	1.300	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148684	2020-08-23 09:52:37
2318	ทองจินดา สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148685	2022-12-27 10:48:59
2319	ทวีทรัพย์ เสนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148686	2025-10-26 13:06:29
2320	เจริญพรรณ ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148688	2016-07-26 12:27:40
2321	มิตรไมตรีเยาวราช 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148689	2015-09-15 10:04:10
2322	รุ่งเจริญเยาวาราช ตำหรุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14869	2016-09-15 00:00:00
2323	แม่แผ่ว5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148692	2014-05-21 16:44:14
2324	วรกาญจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148693	2017-02-10 13:53:43
2325	ทองวิรัตน์ องครักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148694	2016-05-05 14:25:49
2326	ทองจินดา สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148697	2019-07-25 15:32:36
2327	แม่สังเวียน พระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148698	2017-06-03 12:03:06
2328	ทองใบ1 (ลูกชายคนเล็ก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148699	2022-03-05 14:27:13
2329	โชคไพศาล แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1487	2022-01-22 15:34:57
2330	เยาวราชฉลองกรุง5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148701	2017-05-10 16:51:48
2331	หวังทองดี 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148702	2016-08-11 10:30:55
2332	รุ่งเรืองสิน เสนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148703	2014-02-08 16:06:52
2333	จิบเส็ง นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148704	2014-02-09 13:34:39
2334	เกียวเยาวราช1 อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148705	2015-01-15 14:20:12
2335	เต็กเซ่งเฮง2 อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148706	2025-06-09 10:34:28
2336	ก๊วยเซ่งเฮง สะพานควาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148708	2016-07-05 15:39:26
2337	บางนา เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148709	2014-02-18 13:24:36
2338	ทับทิมทอง สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148711	2022-03-16 15:22:33
2339	เพชรทองสุวรรณกิจ ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148712	2020-05-02 13:26:34
2340	เยาวราชคลอง3(พี่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148713	2016-09-20 12:35:39
2341	ตั๊กเซ่งฮง 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148714	2017-05-27 09:16:49
2342	รัษฎา ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148715	2022-11-03 11:41:00
2343	เพชรไพลิน สกล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148716	2024-01-10 13:35:08
2344	ส.เยาวราช มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148717	2018-02-08 18:19:15
2345	พงษ์เจริญ ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148718	2015-03-18 11:51:54
2346	พวงเพชร ทุ่งคอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148719	2025-07-05 11:54:25
2347	เอกรัตน์ นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14872	2014-12-24 13:37:53
2348	เยาวราชชนแดน เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148721	2016-02-28 13:12:53
2349	เยาวราชคลอง2 ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148722	2014-05-04 13:06:48
2350	ไทยเหรียญทอง หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148725	2024-03-22 15:45:46
2351	จิรศักดิ์สุวรรณ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148726	2014-11-23 16:36:02
2352	เอกอนันต์เยาวราช มหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148727	2016-04-29 08:55:21
2353	ศิริสิน มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148728	2015-06-19 11:00:16
2354	คุณซ้อสุปราณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148729	2016-02-18 10:04:02
2355	คุณพิเชษฐ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148731	2014-03-28 11:57:47
2356	เจ๊จูเพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148732	2016-06-05 14:07:30
2357	ทวีชัย9 อ้อมใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148734	2022-01-14 16:50:21
2358	ตงเฮง ทุ่งสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148736	2015-10-12 11:48:52
2359	ทองใบ สะพานควาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148737	2024-05-16 15:01:07
2360	เอกทวี ห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148737	2025-10-24 14:54:25
2361	แม่วรรณี8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148739	2024-02-13 11:39:11
2362	กมลพรรณ ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148741	2015-02-06 00:00:00
2363	ไทยทวี อ่อนนุช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148742	2025-09-03 10:12:39
2364	ศรีทอง2 กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148743	2014-04-08 15:26:32
2365	ช่างเหลียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148744	2018-09-13 13:55:54
2366	จองกาญจนา (จูน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148746	2016-03-30 16:15:22
2367	อุเทน ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148746	2025-09-15 10:40:17
2368	เยาวราชปลาเงินปลาทอง (เชียงคำ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148747	2022-06-21 09:37:13
2369	ดงเซ่ง นราธิวาส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148748	2014-05-03 00:00:00
2370	แม่สุพร 2 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148749	2022-12-08 10:58:27
2371	เยาวราชเอก บิ๊กซี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14875	2017-09-22 16:16:10
2372	แม่วิไลวรรณ นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148751	2025-10-21 13:05:13
2373	สมเกียรติเยาวราช สี่มุมเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148753	2021-03-13 17:30:23
2374	เจริญมณี รามอินทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148755	2014-05-12 17:01:32
2375	ซ่งเฮงหลีกิมกี่ สุขุมวิท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148756	2015-05-05 00:00:00
2376	จินวัตร์ พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148757	2025-09-19 13:31:06
2377	เยาวราชฉลองกรุง4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148758	2019-03-21 12:01:30
2378	ช.ยงศิลป บางลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148759	2023-01-13 16:54:57
2379	อุษณี47	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14876	2014-06-01 11:39:49
2380	อุษณี48	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148762	2014-06-04 12:47:43
2381	อุษณี49	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148763	2014-05-30 15:46:10
2382	อุษณี50	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148764	2014-05-30 15:46:25
2383	ทองดีเยาวราช ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148765	2018-05-03 13:32:49
2384	พนักงานส้ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148766	2014-06-13 15:21:01
2385	เจียงเซ่งเฮง (ทวิชช่าง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148767	2023-10-20 12:55:13
2386	คุณอาจารย์จินตนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14877	2014-06-19 16:32:21
2387	แสงเพชร ศรีสะเกษ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148772	2024-06-21 15:10:52
2388	ไทยทองใบ1 ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148773	2014-06-19 15:50:35
2389	ไทยทองใบ2 ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148774	2014-06-19 15:46:18
2390	แสงทองใบพระโขนง ลูก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148775	2014-06-18 10:00:12
2391	โต๊ะกังห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148776	2022-04-03 13:40:02
2392	แก้วนิมิต องครักษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148777	2022-03-06 10:33:56
2393	เทพพิทักษ์3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148778	2024-10-22 11:43:01
2394	ไทยอุดม หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14878	2025-09-18 15:32:21
2395	ศรีโต๊ะกังเซ็นจูรี่ (ร้านเพชร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148781	2023-10-20 13:17:16
2396	แก้วสุวรรณ2 กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148782	2022-04-21 16:21:07
2397	คุณบัณฑิต(หมุยฮะ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148783	2022-11-24 16:02:03
2398	บริบูรณ์ พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148785	2024-02-01 12:55:13
2399	ช.สันติสุข บ้านเขว้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148786	2023-10-07 13:40:59
2400	แม่สายใจ 3 ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148787	2015-10-27 00:00:00
2401	เพชรทองคำ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148788	2015-11-03 09:25:12
2402	แม่บุญรอดโกสุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14879	2020-01-09 17:41:03
2403	ไทยสวัสดิ์ลำปาง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148791	2014-08-15 11:30:08
2404	จิรศักดิสุวรรณ2 ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148792	2014-09-21 14:41:31
2405	พนักงานขวัญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148793	2025-10-09 09:49:29
2406	พุทเจริญสุข บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148794	2018-08-31 16:46:54
2407	ทรัพย์ไพบูลย์ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148795	2016-11-09 12:27:57
2408	ช่างพจน์	-119268.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148796	2016-06-16 15:39:39
2409	เจริญทรัพย์ ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148797	2014-08-15 15:07:03
2410	โพธิ์ทอง9 นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1488	2014-08-02 15:29:31
2411	มังกรหยก เชียงใหม่	-7919954.00	185.350	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148801	2025-10-26 14:40:32
2412	ง่วนเซ่งหลี อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148821	2014-08-15 12:59:06
2413	ทองสยาม เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148823	2021-09-12 15:11:00
2414	เฮง เฮง มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148825	2018-09-10 14:44:38
2415	จงเจริญเทพสถิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148826	2019-03-06 16:46:06
2416	ตั้งฮะล้ง ห้วยขวาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148828	2014-08-22 14:19:41
2417	เยาวราชเมกาบางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14883	2015-06-24 11:33:29
2418	เยาวราชสะแกงาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148832	2021-03-10 16:02:05
2419	บุญสุวรรณ ตลาดใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148835	2014-09-21 14:54:34
2420	เหลี่ยนหม่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148837	2023-03-15 16:01:16
2421	ทองเซ็นเตอร์3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148839	2021-11-03 16:38:09
2422	แม่ซิวลั้ง ฮอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148842	2014-09-09 13:52:50
2423	พนักงานเปล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148843	2014-12-23 12:33:26
2424	อุเทน ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148844	2021-03-28 10:47:09
2425	บุญสุวรรณ แปดริ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148846	2014-09-15 12:57:11
2426	คุณจ๊ะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148847	2014-10-07 10:27:28
2427	ธนูทอง กบินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148848	2025-06-17 15:01:59
2428	เยาวราช ป่าเหมือด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148849	2025-08-21 13:07:50
2429	ฮั่วเส็งเฮง ลาดพร้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14885	2022-08-09 17:20:55
2430	เยาวราชทรัพย์สมบูรณ์ ทุ่งครุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148851	2015-07-29 12:13:43
2431	เอกเซ่งเฮง อำเภอฝาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148852	2025-01-11 14:51:57
2432	ทองตากสิน 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148853	2024-12-25 09:55:46
2433	ช่างฟ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148855	2025-10-08 15:11:32
2434	เยาวราชศรีขรภูมิ(ซ้อบ๊วย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148857	2014-10-01 12:30:58
2435	ช่างพิชิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148858	2017-06-01 13:53:04
2436	ช่างเอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148859	2016-09-02 10:37:26
2437	ช่างตี๋เล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14886	2020-02-05 12:55:39
2438	คุณประเสริฐ825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148862	2014-10-09 15:44:02
2439	ช่างเนตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148863	2017-01-15 09:49:19
2440	ช่างซาวน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148864	2025-09-16 09:56:33
2441	ช่างตุ่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148865	2019-12-20 18:00:33
2442	ช่างเจน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148866	2016-10-10 09:42:31
2443	ช่างศักดิชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148871	2025-10-07 15:36:06
2444	รุ้งทอง เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148872	2023-04-30 14:25:53
2445	มณเฑียร สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148873	2025-08-31 13:29:26
2446	ทองสวยเยาวราช มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148876	2019-10-30 12:14:34
2447	เอกเซ่งเฮง1 ทัศนา	0.00	488.600	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148877	2025-09-21 11:27:38
2448	ช่างภา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148878	2015-06-04 13:14:48
2449	ปน5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148879	2023-12-15 14:27:05
2450	ช่างเทิม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148882	2022-02-25 14:31:37
2451	อุเทน ขอนแก่น2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148883	2014-11-02 13:05:53
2452	ช่างตุ๊ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148884	2018-07-25 10:46:49
2453	ช่างรุ่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148885	2016-08-16 13:51:46
2454	ช่างแพงมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148886	2020-12-01 16:11:53
2455	เยาวราชกรุงเทพ(ลิ้ม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148887	2024-10-16 11:56:36
2456	แม่บุญมา สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148888	2024-02-08 15:21:58
2457	เยาวราชลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148889	2024-07-20 16:51:42
2458	ช่างธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148892	2014-11-25 13:09:38
2459	ช่างนุ่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148893	2015-09-05 11:38:12
2460	รุ่งโรจน์ บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148894	2016-05-18 12:17:34
2461	ช่างโจ๊ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148895	2020-03-03 13:06:29
2462	ช่างเที๊ยมจั๊ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148896	2020-05-22 15:18:53
2463	พนักงานปอนด์	22429.97	0.000	0.000	15.250	0.000	0.000	0.000	2025-11-20 15:38:54.148897	2025-10-07 12:24:05
2464	เจริญเยาวราช หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148898	2019-04-23 17:33:02
2465	ธราญา พระราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148899	2014-11-01 15:22:33
2466	ดีแสงดี(มนัสนันท์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1489	2015-05-12 12:57:15
2467	พนักงานมิกซ์	20433.46	1.900	0.000	114.300	0.000	0.000	0.000	2025-11-20 15:38:54.148902	2025-10-26 09:25:14
2468	ช่างพายัพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148903	2016-09-30 20:17:03
2469	ช่างโกต๋อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148904	2023-12-12 17:05:21
2470	ช่างสมบัติ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148905	2019-06-29 10:52:52
2471	เจริญชัย สระแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148908	2021-06-12 14:53:02
2472	ย่งเฮง แม่กลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148909	2016-10-06 14:03:29
2473	ช่างนพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14891	2024-12-14 15:25:13
2474	สิงห์ทองคำ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148911	2022-03-01 16:26:48
2475	คูณอนันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148912	2023-06-08 16:26:11
2476	ช่างโรส	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148913	2016-09-30 19:42:51
2477	สมใจอนันต์ มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148914	2018-01-26 16:28:04
2478	ทองสวิส จันทรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148916	2014-11-20 16:04:02
2479	ศรีไทย จันทรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148917	2014-11-16 12:02:52
2480	ช่างแจ๊ค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148918	2016-10-10 14:15:22
2481	ช่างชาญวิทย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148919	2022-05-10 14:00:57
2482	ช่างโต๊ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148921	2016-05-03 14:39:33
2483	ร้อยเปอร์เซนต์ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148923	2022-06-21 16:46:22
2484	กุหลาบ แกลง ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148925	2015-04-25 09:58:47
2485	แต้เช็งหลีเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148926	2024-01-30 15:50:55
2486	ช่างกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148927	2016-09-30 16:53:36
2487	รุ่งเจริญ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148928	2018-08-10 16:39:48
2488	ช่างมุก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148929	2019-12-21 12:26:48
2489	ช่างค่อม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14893	2024-03-27 09:58:15
2490	เยาวราช9 บัญญัติทรัพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148931	2025-07-04 12:03:57
2491	สวัสดี กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148932	2020-07-17 15:19:11
2492	แสงฟ้า ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148933	2014-11-30 12:39:13
2493	ช่างนิว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148935	2016-09-30 18:52:09
2494	กิจมณี มวกเหล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148936	2015-03-04 16:32:10
2495	สินสุวรรณ5 สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148939	2016-11-27 13:33:03
2496	ช่างยุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14894	2016-10-10 09:59:29
2497	พนักงานฝน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148941	2025-09-03 11:17:20
2498	สุวรรณไพศาล สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148942	2015-03-18 14:43:01
2499	ช่างโบว์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148943	2018-05-29 15:16:31
2500	ช่างเหน่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148944	2016-08-09 11:37:22
2501	เพชรทองคิมเฮง อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148945	2016-12-10 16:20:44
2502	เหรียญทอง นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148946	2025-10-17 12:24:14
2503	แม่ติ่ว พังงา	0.00	104.250	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148947	2019-06-11 16:18:25
2504	เยาวราชรามอินทรา กม4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148948	2014-12-03 14:01:26
2505	ฮั้วเฮงล้ง1เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148949	2016-09-24 14:27:05
2506	เยาวราชปะทิว ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14895	2024-11-02 14:20:10
2507	เหรียญทอง สมอทอด	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.148952	2018-11-12 15:33:55
2508	ช่างเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148953	2018-08-29 18:37:20
2509	ช่างเจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148954	2016-09-01 11:08:08
2510	ช่างอนันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148955	2020-04-24 10:58:37
2511	พิมพ์เจริญ กระบี่่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148956	2023-10-11 15:53:01
2512	แสงทองใบ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148957	2022-12-21 11:19:00
2513	แต้ดีฮง บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148958	2016-09-07 17:00:43
2514	จารุกร สนามเป้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14896	2025-10-22 15:16:52
2515	ชัยเจริญ เกาะสมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148961	2025-08-01 14:14:15
2516	ช่างกาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148962	2016-09-30 16:43:04
2517	ไล้กิมกี่ บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148963	2022-11-23 15:51:33
2518	แสงกมล แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148964	2025-03-20 15:14:52
2519	ศรีวิชัย ประจวบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148967	2016-07-02 15:23:01
2520	กรุงเทพเยาวราชสุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148968	2017-03-09 16:57:22
2521	กรุงเทพเยาวาราชอุทุมพรพิสัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148969	2017-07-19 14:10:30
2522	คุณเจี๊ยบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14897	2014-12-23 11:28:07
2523	ช่างสมัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14897	2025-04-23 13:14:11
2524	แมลงปอ เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148971	2015-08-18 08:44:53
2525	NG	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148972	2015-08-27 16:27:48
2526	ช่างหนัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148973	2016-10-10 09:43:41
2527	ช่างสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148976	2016-10-07 09:53:38
2528	ช่างเพ็ญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148977	2016-09-30 19:32:29
2529	ช่างหนูเล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148978	2015-09-29 13:54:42
2530	กรุงเทพ100% จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148979	2016-09-28 15:14:00
2531	ช่างตุ่ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148981	2016-09-30 17:47:15
2532	ช่างประพันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148982	2021-05-02 10:04:59
2533	ช่างบุญเกิด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148983	2024-10-09 13:22:23
2534	ช่างก๊อป	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148983	2014-12-27 14:59:50
2535	เพชรทองโพธิ์ทอง นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148984	2025-06-24 15:34:05
2536	นิวโต๊ะซิ่วฮง แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148985	2015-01-24 16:36:22
2537	เยาวราชบุญศิริ สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148987	2017-07-06 15:25:29
2538	ธนกร เชียงใหม่2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148988	2015-01-10 10:25:26
2539	ช่างสุพัด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148989	2016-09-30 20:35:12
2540	ช่างหลง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14899	2025-09-04 13:02:33
2541	ช่างโสภณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148991	2019-03-15 11:52:51
2542	ช่างตี๋	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148992	2016-10-11 14:00:00
2543	สมบูรณ์ ประตูน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148995	2015-01-12 16:48:42
2544	ช่างสินีนาฏ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148996	2016-09-30 19:36:24
2545	เยาวราชศาลเจ้าไก่่ต่อ นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148997	2025-10-02 08:48:34
2546	เยาวราช1 แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149	2015-01-15 13:42:59
2547	เกียวทอง เกาะช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149001	2021-04-09 17:26:07
2548	ช่างสมบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149002	2016-09-30 19:54:31
2549	ทองแท้ มหาสารคาม(หงษ์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149003	2025-05-31 15:04:34
2550	เอกทวี รามอินทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149004	2024-10-25 11:13:02
2551	กิเลนทอง สำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149005	2015-01-21 14:26:20
2552	เยาวราชโรบินสัน ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149006	2015-03-06 15:55:11
2553	แสนงาม ปัตตานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149008	2021-03-12 16:52:03
2554	โพธิ์ทองเยาวราช นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149009	2024-04-27 15:52:31
2555	ช่างพี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149011	2015-01-27 16:02:39
2556	วัฒนาสิน ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149013	2025-05-20 15:36:54
2557	ธงชัย ดอนสัก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149014	2016-01-20 15:50:21
2558	คุณแอนนา เพื่อนแหม่ม14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149015	2015-01-30 14:33:39
2559	อาฟาร์อ๊อด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149016	2015-01-31 17:32:54
2560	จุฑามาศ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149017	2017-01-15 11:04:00
2561	แม่เที่ยง ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149019	2018-06-17 13:31:18
2562	รุ่งสุวรรณ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14902	2015-02-01 15:42:02
2563	เยาวราชกรุงเทพ นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149021	2015-03-24 17:57:14
2564	ทองใบ1 (สุณิสา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149022	2025-07-14 13:49:22
2565	เยาวราชศรีนครินทร์ สาขา3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149024	2023-08-15 17:37:58
2566	เยาวราชศรีนครินทร์ สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149025	2025-10-22 17:18:10
2567	ทองห้างใหญ่เยาวราช2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149027	2022-03-09 12:55:00
2568	ไท้หลีเฮง ศรีนครินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149028	2025-09-27 11:56:28
2569	จึงฮงหลี บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149029	2015-02-07 10:56:00
2570	เจนถิ่่น2 แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14903	2015-02-10 14:43:26
2571	ช่างมณี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149031	2019-07-05 16:56:20
2572	ตลาดไททองคำ ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149032	2016-09-25 14:39:56
2573	แม่ทองคำ วัชรพล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149033	2021-03-20 17:21:25
2574	T C T Gold ประเวศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149034	2015-04-26 14:38:51
2575	100% ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149035	2019-05-15 18:14:31
2576	แม่กิมหงส์เยาวราช บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149037	2025-03-23 14:45:26
2577	มังกรหยก คูเมือง เฮียเกี๊ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149039	2022-01-15 15:52:52
2578	ศิริมาลี ทุ่งใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14904	2015-06-27 17:01:59
2579	ช่างบ๋อม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149043	2016-10-07 09:52:33
2580	เบ๊เฮงฮวด ประจวบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149044	2025-10-26 12:42:40
2581	แม่ศรีคำ ยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149045	2016-01-28 15:10:12
2582	เยาวราชมหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149046	2015-05-08 13:42:27
2583	ช่างวัฒน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149048	2019-07-05 16:59:17
2584	เพชรยินดี ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149049	2015-02-24 14:40:32
2585	ช่างฉลอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14905	2025-07-04 15:11:49
2586	มังกรคู่ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149051	2020-02-26 14:36:46
2587	สวัสดี เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149052	2015-02-27 15:37:56
2588	ปุ้ยเยาวราช ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149053	2025-09-04 13:23:59
2938	ช่างมานุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150387	2016-10-01 14:30:57
2589	เซ้งเฮง ชุมแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149054	2021-10-09 14:48:09
2590	แม่กิมจัง ท่าม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149055	2018-11-24 17:24:50
2591	เดือนเพ็ญ บ้านบึง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149058	2022-05-20 13:02:41
2592	เยาวราชพัทยา นาเกลือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149059	2016-05-11 13:54:32
2593	ไทยสมบูรณ์1 ทุ่งสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14906	2019-03-13 18:23:12
2594	ไทยสมบูรณ์2 (คุณเบญ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149061	2015-08-14 13:39:52
2595	เจดีย์ทอง สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149062	2025-09-24 16:22:37
2596	พรหมนิมิต รังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149063	2015-03-08 12:18:54
2597	ช่างกิตติ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149065	2015-03-10 12:02:04
2598	ทองใบหยก หนองบัวลำภุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149066	2022-11-04 14:47:36
2599	ทองสวย เสริมไทยพลาซ่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149067	2015-03-12 09:35:32
2600	แสงทองใบ(ร้านแรก) จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149068	2022-07-13 14:39:13
2601	ช่างชาญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149069	2016-09-07 12:34:29
2602	เยาวราชกรุงเทพ จอมพระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14907	2015-03-14 11:49:42
2603	เพชรทองมัสลิน เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149073	2025-03-16 14:36:49
2604	อัญญรัตน์ หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149074	2015-12-18 16:13:36
2605	ไท้เฮง ท่าพระจันทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149075	2023-08-01 09:49:58
2606	ศรีสมบูรณ์๙๙ บ้านโป่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149076	2023-03-09 14:43:12
2607	มหานคร อ้อมใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149077	2025-10-18 15:18:16
2608	ช่างแว่นแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149078	2024-12-24 11:09:13
2609	เจ้าสัว บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14908	2015-07-17 14:09:07
2610	ทรัพย์แหลมทองโพนทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149081	2020-08-25 14:56:08
2611	เยาวราชอำเภอบรรพตพิสัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149082	2024-01-19 12:34:03
2612	ทองดีเยาวราช หัวตะเข้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149085	2023-10-09 15:18:37
2613	ทองเจริญชัย พัฒนาการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149086	2021-05-11 14:32:36
2614	แม่เอี่ยวเค็ง อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149087	2017-11-02 17:21:57
2615	นรเศรษฐ์ ลำนารายณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149088	2025-07-29 15:20:37
2616	วัฒนสิน สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14909	2024-08-31 10:14:00
2617	ริช จิวเวลรี่ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149091	2015-09-08 12:00:49
2618	เยาวราชแม่เข็มเพชร ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149092	2017-01-06 10:47:45
2619	ช่างเยาว์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149093	2015-04-08 15:08:13
2620	เอื้ออาทร ทุ่งครุ	0.00	14.500	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149094	2017-09-14 17:13:47
2621	เอ็งน่ำเฮง(คุณต้น) อุดรธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149095	2015-09-14 15:19:55
2622	สิทธิพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149097	2015-08-07 14:26:45
2623	โห่ตงเส่ง(แม่ตังกวย) อุทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149097	2015-05-12 17:17:35
2624	เพชรรัตน์ เดอะมอลล์ท่าพระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149099	2015-05-06 10:30:56
2625	ไทยเฮง แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1491	2022-09-13 16:25:49
2626	คุณสุรัสวดี ตรีโรจน์วงศ์์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149101	2016-03-24 15:45:34
2627	ทรัพย์ไพศาล นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149102	2016-01-16 13:52:47
2628	เยาวราช99 บางขุนเทียน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149104	2024-03-29 15:26:19
2629	ไทยอานันท์ สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149105	2018-04-25 14:28:43
2630	นำเฮงเยาวราช ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149107	2018-03-24 16:18:02
2631	ช่างต้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149108	2016-05-07 13:37:36
2632	เจริญไทย เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149108	2015-09-05 14:24:34
2633	คุณโส BOA	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149109	2023-11-15 14:57:38
2634	ภูเก็ตตลาดกระทู้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14911	2025-10-18 10:35:31
2635	ทองสุวรรณ ด่านขุนทด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149111	2023-10-07 15:34:12
2636	เพชรทองสุริเย หันคา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149112	2015-09-20 13:44:15
2637	ช่างพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149113	2024-08-30 13:41:33
2638	ศรีสุพร ศรีประจันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149114	2017-04-23 13:04:11
2639	ช่างบูม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149115	2023-08-05 15:32:20
2640	อรนุช ตราดาว อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149118	2015-06-04 16:50:52
2641	ช่างสายันต์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14912	2015-06-06 14:04:55
2642	แม่กิมตี จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149121	2019-04-10 17:20:34
2643	เทวินทร์ สุวินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149122	2017-01-24 10:00:23
2644	สัจจาภรณ์ จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149123	2022-04-26 16:22:21
2645	ยินดีมีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149124	2015-10-28 16:21:52
2646	เพชรทอง99 สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149126	2025-05-21 14:37:28
2647	เยาวราชสีลม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149127	2018-10-10 14:39:56
2648	สินไพศาล ดอยสะเก็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149129	2017-01-18 17:13:46
2649	นครพรรณ โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14913	2016-08-28 14:46:16
2650	ช่างอ้อม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149131	2016-09-30 21:01:05
2651	เฮงเซ่งเฮง คุณฝน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149132	2025-03-07 09:56:26
2652	ไทยเจริญ หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149134	2019-07-25 11:49:16
2653	ช่างวัฒนารมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149135	2019-11-26 11:09:34
2654	ช่างอำนาจ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149136	2016-10-08 10:18:43
2655	วิทเฮงหลี หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149137	2015-07-10 16:54:55
2656	ใต้เชียงเฮง 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149138	2021-03-24 16:52:56
2657	ช่างสมศักดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149139	2016-06-29 13:09:30
2658	ทองดี ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14914	2015-07-14 16:33:35
2659	เยาวราชบิ๊กซี อุบล สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149141	2016-04-02 14:40:16
2660	กิมโต๊ะกัง พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149142	2019-04-03 19:12:13
2661	วนิดา ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149143	2023-03-01 16:11:49
2662	หยุงฝา เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149144	2017-11-21 16:16:55
2663	ทองสุกเยาวราช บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149145	2016-12-02 14:45:09
2664	เพชรทองใบเยาวราช บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149147	2015-09-23 16:10:49
2665	๑ เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149148	2025-03-27 13:11:23
2666	มิ่งมงคล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14915	2022-03-29 13:18:47
2667	นำโชค อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149151	2015-07-24 13:54:42
2668	แม่วรรณี ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149152	2019-01-26 16:31:47
2669	สมพิศเพชรทอง พยัคฆ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149153	2016-01-08 15:23:19
2670	เยาวราชอุทุมพร อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149154	2017-02-18 14:46:12
2671	ดีดีรังสิต3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149155	2023-08-17 15:19:30
2672	บุญครองพร สุพรรณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149156	2024-11-13 16:19:33
2673	ทองไทย พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149158	2015-11-26 13:12:05
2674	คุณฉ่อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149159	2015-07-31 11:02:26
2675	รุ่งทรัพย์ ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14916	2024-10-14 11:03:18
2676	น้อยเซ็นเตอร์ แม่ฮ่องสอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149163	2018-01-23 13:31:16
2677	แสงวิวัฒน์ เตาปูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149164	2019-11-27 15:17:34
2678	เยาวราชเชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149165	2022-12-20 17:13:09
2679	ช่างเชง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149166	2025-10-15 10:48:10
2680	กิ้มฉุ่งเฮง สมุทรสงคราม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149167	2025-08-28 14:20:56
2681	จารุวัฒน์ เจ็ดยอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149168	2020-03-13 17:24:39
2682	ทองสวิส ตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149169	2025-08-30 13:55:02
2683	สมสุวรรณ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14917	2023-12-06 17:07:12
2684	เพชรทองนิธิวัชร์ พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149171	2017-09-30 14:51:13
2685	แสงสว่าง กาฬสินธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149172	2017-07-04 14:35:31
2686	นพเก้า อุตรดิตถ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149173	2015-08-10 12:21:24
2687	ง่วนเซ่งเฮง สุขุมวิท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149174	2015-08-11 10:12:06
2688	ช่างแป้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149179	2015-08-13 10:14:38
2689	แม่ทองใบ BigC สะพานควาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14918	2015-08-18 14:03:12
2690	คุณหมอศุภชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149181	2015-09-01 08:51:07
2691	เยาวราชหนองส้ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149182	2024-12-24 13:05:45
2692	อรกัญญา ชัยนาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149183	2016-05-21 09:48:30
2693	คุณชาตรี (ร้านแม่พร)	0.00	17.850	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149184	2025-10-26 14:11:46
2694	ชัยศิลป์ อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149184	2017-09-29 14:11:05
2695	นำเจริญ3 พี่โหน่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149186	2016-09-10 17:49:44
2696	เกียหงวน สุราษฎร์ธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149187	2018-03-15 15:16:54
2697	สาโรช บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149189	2015-09-04 12:46:14
2698	พรมารี สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14919	2023-03-29 16:12:41
2699	ตั้งทองใบ กรุงเทพกรีฑา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149191	2023-11-28 15:37:32
2700	เยาวราชกรุงเทพ อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149193	2016-01-30 15:18:55
2701	กัลยา ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149194	2016-02-03 14:28:44
2702	ช่างวีร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149196	2019-02-01 12:39:30
2703	ฮะเฮงหลี ถนนจันทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149197	2015-09-18 12:45:14
2704	แม่สุขใจ3สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149199	2015-09-18 14:44:11
2705	ศิริทองใบ งามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1492	2019-08-03 13:22:11
2706	เจริญทรัพย์ พัทยากลาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149201	2025-10-08 17:01:49
2707	ช่างโชคชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149202	2016-03-05 11:08:30
2708	ผลไพศาล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149203	2025-10-16 16:04:54
2709	ปิ่นเจริญ ช่างอากาศอุทิศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149204	2016-12-22 11:42:54
2710	กรุงเทพ ย อำเภอท่าศาลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149205	2017-06-09 13:19:22
2711	คุณแน๊ต	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.149207	2025-10-15 17:10:47
2712	ช่างเพียว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149209	2016-09-30 18:54:07
2713	เพชร ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14921	2016-11-19 12:02:06
2714	ปาลิกา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149211	2016-07-01 12:34:32
2715	ช่างสากล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149212	2018-06-29 13:13:28
2716	กิมเฮงเฮง ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149213	2015-10-10 14:35:43
2717	เพชรพัฒนา2 เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149214	2016-08-04 10:31:43
2718	GG	0.00	0.000	0.000	15244.000	0.000	-4031.150	0.000	2025-11-20 15:38:54.149215	2025-10-24 14:43:46
2719	MTS	0.00	0.000	0.000	15396.450	0.000	215000.000	0.000	2025-11-20 15:38:54.149216	2025-10-25 12:18:30
2720	HUA	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149217	2019-05-03 11:31:48
2721	เฮงเซ่งเฮง สาขา1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149218	2023-09-05 17:39:23
2722	LCH	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149219	2025-10-25 11:22:03
2723	แม่ศรี บางวัว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14922	2018-03-06 18:24:45
2724	ทองเจริญ นนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149222	2015-10-16 14:00:45
2725	แม่วรรณี9 ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149223	2025-07-16 11:40:06
2726	จันทร์ประสิทธิ์ เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149224	2016-11-11 14:53:12
2727	เอี๊ยะฮั้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149225	2016-02-11 13:05:48
2728	ทองเจ้จู3 เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149226	2015-10-28 13:53:24
2729	เรืองชัย แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149227	2025-04-06 14:58:04
2730	ทองเพชรพลอย พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149228	2015-11-21 14:38:17
2731	คุณญาติซ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149229	2015-11-01 15:08:22
2732	ทองธารา เยาวราช	-2667.00	61.600	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14923	2020-08-23 09:52:51
2733	ช่างโก๊ะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149231	2015-11-03 13:13:56
2734	คุณวรวิทย์ วิทยอำนวยคุณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149232	2022-08-02 09:05:13
2735	เพชรี อุดมสุข	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149233	2017-08-23 17:41:17
2736	โต๊ะกัง กรุงเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149237	2017-06-08 09:31:36
2737	เจริญสุข จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149238	2018-05-12 17:22:31
2738	เพชรไพลิน พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149239	2015-11-21 15:37:38
2739	ไทยเจริญ9999 ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14924	2017-01-20 16:04:21
2740	ปิ่นเจริญ ดอนเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149241	2017-07-16 11:21:16
2741	เทพทอง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149242	2016-11-19 13:46:54
2742	ไชยณรงค์ หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149243	2016-01-14 13:20:33
2743	แม่ทองคำ มาบตาพุด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149244	2016-02-17 12:46:43
2744	เศรษฐวุฒิไกร เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149245	2020-06-27 00:00:00
2745	ต้นทองเยาวราช99	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149246	2016-09-21 13:24:01
2746	GT	0.00	0.000	0.000	-25914.800	0.000	-85000.000	0.000	2025-11-20 15:38:54.149247	2025-10-24 11:07:00
2747	ศรีสุวรรณ3ปราณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149248	2021-09-25 15:52:39
2748	สินทวีเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14925	2015-12-23 18:08:36
2749	จินง้วนเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149251	2016-09-22 13:04:57
2750	อินเตอร์ปัตตานี2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149252	2016-09-04 11:12:07
2751	ซ้อรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149253	2021-12-29 11:05:00
2752	เยาวราชหนองพอกร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149254	2018-07-14 16:29:13
2753	โกลด์สมิทภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149255	2016-06-30 14:48:02
2754	หมอจงเจตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149256	2024-01-12 16:41:56
2755	คุณปลาเพื่อนเสี่ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149257	2020-02-22 12:06:33
2756	IG	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149258	2023-06-01 10:01:18
2757	เกริกก้องชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149259	2025-07-14 15:19:27
2758	ทรัพย์ทวีเยาวราชกาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.14926	2024-06-12 16:23:00
2759	ไทยกนกเยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149261	2015-12-18 14:14:27
2760	สุริยะ2เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149262	2025-09-07 14:59:29
2761	กรุงเทพเยาวราชเพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149264	2025-09-02 13:22:56
2762	ศรีทองพระขโนง(พ่อ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.149266	2016-02-19 11:19:02
2763	กองทุนBBL	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150145	2016-01-05 14:27:00
2764	กองทุนSCB	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150148	2016-01-05 10:38:05
2765	กองทุนBAY	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15015	2016-01-05 14:15:33
2766	กองทุนTFB	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150151	2016-01-05 13:51:27
2767	เกัานาฬิกาพิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150153	2025-10-25 14:20:56
2768	เยาวราชแม่ทาลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150157	2019-01-29 17:02:08
2769	เมืองทองพิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150159	2015-12-26 16:34:40
2770	ช่างก้อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15016	2016-10-08 10:21:35
2771	แม่ทองยุ่น เยาวราชชัยภุมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150161	2017-01-10 16:49:58
2772	ทองบูรพา นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150163	2016-01-09 10:14:51
2773	กวงซิน สิงห์บุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150166	2016-01-09 13:18:41
2774	Bao	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150167	2024-11-07 14:44:24
2775	โชควัฒนา ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150168	2025-10-08 14:01:49
2776	หงษ์คูฟ้า สาขากรุงเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15017	2023-10-15 14:54:33
2777	ทองสากลเยาวราช นครนายก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150171	2025-05-06 14:34:42
2778	เซ่งฮวดหลี ท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150173	2016-01-17 13:43:20
2779	ไทยนิยม3 ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150174	2025-10-22 15:48:03
2780	ช่างพรเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150175	2016-01-19 13:51:25
2781	เจ เค เจริญ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150176	2016-01-19 16:10:28
2782	ทองสำรวย ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150178	2016-06-18 09:56:59
2783	โชคดีเยาวราช มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15018	2016-01-20 09:54:20
2784	ทองกรุงเทพเยาวราชอ.ขุขันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150182	2018-03-21 13:27:10
2785	เพชรพลอยดี บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150185	2022-12-21 16:38:34
2786	ทองไทยสาขา3 ราไวย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150186	2016-01-27 12:17:01
2787	ธนสุวรรณ บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150187	2016-01-27 12:20:21
2788	แม่อุษา เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150188	2016-11-08 10:53:58
2789	แม่สุวรรณา1 สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15019	2019-01-08 18:30:43
2790	ฮวดเซ่งเฮง บางปลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150191	2016-09-22 14:13:22
2791	ตั้งเฮงเฮง ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150192	2017-04-05 18:06:15
2792	รุ่งเรือง ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150194	2025-10-26 10:12:04
2793	กระต่ายคู่ บางบ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150195	2022-12-15 16:51:47
2794	ทวีชัย9  ด่านชั่่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150196	2021-02-17 16:07:33
2795	ทองนงเยาว์ เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150198	2025-10-15 12:15:02
2796	มังกรเยาวราช บางปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150199	2016-06-09 11:06:30
2797	ช่างบรรเทิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150202	2020-02-25 12:19:48
2798	ขวัญทองเยาวราช พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150203	2023-04-08 11:55:34
2799	พรเจริญ2พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150205	2024-02-28 16:55:19
2800	ไท้เฮงล้ง ตราช้าง1 โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150208	2016-09-30 11:24:17
2801	ช่างหน่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150209	2016-10-10 09:44:17
2802	กาญจนาภิเษก2 ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15021	2016-02-24 14:46:59
2803	โสมมภัส ปัตตานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150211	2019-02-12 10:35:12
2804	แม่ทองสวยเยาวราช ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150213	2021-03-12 16:14:41
2805	ใต้เฮงหลี ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150214	2024-12-14 13:41:32
2806	นันทชัย เวียงแแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150215	2016-07-09 11:09:52
2807	นันทชัย เวียงแว่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150216	2016-03-01 10:32:04
2808	โต๊ะกังมาบุญครอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150217	2024-06-20 16:00:25
2809	ทองพันชั่ง บ้านไผ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15022	2019-01-30 17:07:09
2810	เยาวราชทรัพย์บุญชัย สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150221	2018-02-21 18:25:57
2811	แสงสุวรรณ น่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150222	2016-06-23 16:50:06
2812	แสงเจริญ ทุ่งเสลี่่ยง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150224	2016-05-14 14:55:12
2813	แสงไทย สวรรคโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150225	2016-05-14 14:41:02
2814	ดีเจริญ แม่ฮ่องสอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150225	2024-03-16 15:38:26
2815	แม่สุจินต์สามชุก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150227	2023-11-03 09:55:05
2816	เที่ยงธรรม พระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150228	2025-01-16 13:47:30
2817	ย่งอา พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150229	2019-06-23 14:43:38
2818	คุณสุทธิพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15023	2016-03-10 13:23:17
2819	คุณจี๋รัดสาด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150231	2016-04-05 08:57:54
2820	ทองธเนศ ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150232	2025-08-13 16:04:41
2821	โอเอะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150235	2016-03-14 09:53:53
2822	ช่างซิวเจ๊	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150236	2016-03-15 14:03:40
2823	ทวีชัย9สาย5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150238	2016-03-18 16:02:52
2824	ช่างนกน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150239	2016-09-30 19:24:12
2825	เยาวราชฉลองกรุงอมตะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15024	2025-10-22 15:37:03
2826	เยาวราชบางพลีซิตี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150241	2016-06-10 14:34:38
2827	ยิ่งเจริญบุรีรัมย์	0.00	0.000	0.000	762.200	0.000	0.000	0.000	2025-11-20 15:38:54.150242	2025-10-22 17:14:25
2828	อุ่ยอุทัย2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150243	2016-03-24 15:11:54
2829	เพชรทอง99พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150244	2024-06-23 14:22:44
2830	ทองไทย ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150245	2016-09-28 09:06:40
2831	พรวิสันต์บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150248	2025-06-07 12:09:13
2832	GT เพิ่มทุน	-500000.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150249	2016-04-05 13:28:17
2833	ทองวิจิตร พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150252	2023-10-21 15:44:11
2834	รอฮานีสงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150254	2016-04-19 17:40:08
2835	นพคุณ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150255	2017-01-08 11:46:52
2836	เยาวราชหนองหอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150257	2019-06-11 11:29:19
2837	กาญจนาเยาวราช พันท้าย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150258	2016-04-24 15:13:02
2838	ช่างแหลม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150259	2016-04-27 14:30:09
2839	แพรพลอยมณีพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150261	2016-05-10 15:34:53
2840	แม่พร (ซ้อยา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150262	2016-05-21 10:34:23
2841	ช่างโต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150263	2018-07-26 10:03:10
2842	เจริญสิน สูงเนิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150264	2016-05-14 00:00:00
2843	เพชรพลอย กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150265	2016-12-16 10:11:26
2844	เยาวราชบางโฉลง สุวรรรณภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150266	2016-05-17 16:20:45
2845	ยิ่งเจริญ พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150269	2016-05-18 13:52:54
2846	เพชรมังกรพระบาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15027	2022-03-26 14:25:06
2847	เป้าเฮงหลี2 ทุ่งใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150272	2018-04-27 14:20:53
2848	แม่ทองหล่ออ้อมน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150273	2016-05-28 12:00:02
2849	พลอยเพชร อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150274	2018-10-10 14:27:47
2850	ฮ้อฮั่วเฮง ศาลายา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150275	2019-03-28 17:22:56
2851	พัฒนาภรณ์ พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150276	2017-07-12 15:31:45
2852	ฉัตรสุวรรณ ตรากบ โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150278	2022-03-23 16:55:58
2853	ธารทองเพชรบูรณ์ 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150279	2016-06-23 09:44:53
2854	รุ่งเจริญ สำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15028	2016-07-05 16:02:58
2855	ลิ้มเคียนฮวด 3 กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150281	2016-09-13 12:14:03
2856	โต๊ะกังชัยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150282	2025-01-19 14:22:18
2857	บ้วนเฮงลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150285	2018-03-07 18:18:12
2858	ช่างสาลี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150286	2016-10-07 13:27:53
2859	โกลด์เด้น99	-12921318.88	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150287	2025-10-14 12:43:30
2860	ช่างแม็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150288	2016-06-30 09:36:38
2861	เพชรรัชนีนครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150289	2022-05-31 11:40:46
2862	ทองประชานิเวศน์ 1 จตุจักร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15029	2023-08-06 14:05:26
2939	ช่างแอ๊ะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150388	2016-10-06 14:01:17
2863	เยาวราชกรุงเทพเม้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150293	2020-07-22 14:57:14
2864	ช่างจักร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150294	2016-09-30 16:46:03
2865	ศิริเมืองทอง โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150296	2021-10-01 13:10:57
2866	เดือนเพ็ญ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150297	2016-07-13 15:38:15
2867	นภาพันธ์เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150299	2016-07-22 15:59:51
2868	ใบหยก พิมาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1503	2016-07-23 13:52:09
2869	ตั้งเฮงเฮงกม8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150303	2024-08-07 15:26:24
2870	เจริญทรัพย์ อมตะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150304	2018-03-07 10:57:29
2871	ทองพัฒนา จุน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150305	2018-05-27 14:45:03
2872	บ้วนเฮง2 ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150307	2019-03-15 16:36:31
2873	มีชัย สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150308	2016-08-07 13:19:57
2874	เพชรอู่ทอง เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150309	2018-09-11 16:58:56
2875	แก้วเยาวราชบุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15031	2022-11-23 15:47:47
2876	เยาวราชบางกอกวัดไทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150311	2020-07-13 08:55:46
2877	ซังเซ่งเฮง บางเสาธง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150312	2022-06-24 12:07:07
2878	ใจดี มีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150313	2025-10-18 14:24:09
2879	แม่กิมเฮียงสมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150315	2023-01-06 17:54:03
2880	แต้ซังหลี โคราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150316	2019-03-28 16:40:02
2881	สิริชัย นครสวรรค์	0.00	0.000	0.000	381.100	0.000	0.000	0.000	2025-11-20 15:38:54.150318	2025-10-22 17:06:06
2882	หลีเซ่งเฮง สะพานใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150319	2025-02-23 14:20:56
2883	ช่างน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15032	2016-10-01 14:37:34
2884	เยาวราชขอนแก่น อำเภอเมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150321	2025-06-17 13:48:06
2885	คุณพี่พิชิต (เพื่อนเสี่ย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150322	2024-07-18 15:29:55
2886	นิมิต สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150324	2025-10-09 16:33:38
2887	เพชรบูรพา กบินทร์บุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150325	2025-02-07 11:57:45
2888	บัวพัฒนา ลาดปลาเค้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150326	2025-10-21 16:59:13
2889	เดือนเพ็ญ พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150327	2016-09-24 15:30:52
2890	วัชรินทร์โกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150328	2022-12-27 17:05:41
2891	ช่างคุงกัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150329	2016-09-30 16:41:26
2892	ช่่างกิมง้วน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15033	2017-07-11 14:53:44
2893	ช่างชิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150333	2016-09-30 17:07:14
2894	ช่างชมพู่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150334	2022-01-13 11:01:13
2895	ช่างเซ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150336	2024-06-11 13:53:10
2896	ช่างเดฟ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150337	2016-09-30 17:20:37
2897	ช่างอาเม้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150338	2016-09-30 17:19:46
2898	ช่างจตุพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150339	2018-10-02 14:57:32
2899	ช่างจิรัชฌา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15034	2024-11-05 15:04:56
2900	ช่างเต็กเซ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150341	2016-10-11 11:02:17
2901	ช่างไล้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150342	2016-10-08 10:22:49
2902	ช่างช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150343	2016-09-30 17:49:46
2903	ช่างเต้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150344	2024-08-27 12:47:17
2904	ช่างซ้อซ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150345	2016-09-30 17:55:26
2905	ช่างต๋อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150346	2018-04-02 12:29:50
2906	ช่างชุดา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150349	2021-07-06 14:09:37
2907	ช่างปิ่นทองดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15035	2025-04-01 16:53:16
2908	ช่างไถ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150351	2016-10-07 10:23:08
2909	ช่างแท็ป	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150352	2016-09-30 18:34:06
2910	ช่างธวัช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150353	2016-09-30 18:43:08
2911	ช่างทองไท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150354	2016-09-30 18:43:53
2912	ช่างเบิร์ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150355	2016-10-07 11:30:24
2913	ช่างนิติยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150356	2020-10-14 14:43:56
2914	ช่างไพฑูรย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150357	2016-09-30 19:25:00
2915	ช่างพงษ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150358	2016-09-30 19:29:37
2916	ช่างประณีต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150359	2016-10-07 13:30:11
2917	ช่างนุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15036	2019-01-30 13:15:01
2918	ช่างพิมพ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150362	2019-12-18 14:35:53
2919	ช่างภูสิทธิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150363	2016-09-30 19:53:23
2920	ช่างสถาพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150364	2016-09-30 19:51:27
2921	ช่างพิเชษฐ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150365	2016-09-30 20:02:45
2922	ช่างสง่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150366	2016-10-07 11:43:41
2923	ช่างบัญชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150367	2021-06-15 13:37:06
2924	ช่างวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150368	2016-10-11 14:07:11
2925	ช่างวิทย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150369	2016-09-30 20:20:40
2926	ช่างวิเชียร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15037	2016-09-30 20:23:24
2927	ช่างศักดิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150372	2016-10-08 12:20:09
2928	ช่างเอี๋ยว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150373	2016-09-30 20:36:32
2929	ช่างสายสุนีย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150374	2025-03-14 11:47:38
2930	ช่างสมคิด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15038	2021-02-25 14:36:14
2931	ช่างหนุ่ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150381	2016-10-11 09:38:06
2932	ช่างแหนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150382	2016-09-30 20:41:10
2933	ช่างอุทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150383	2016-09-30 21:05:28
2934	ช่างอนุรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150384	2016-09-30 21:04:57
2935	ช่างฮั้งใช้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150385	2016-10-08 13:54:23
2936	ช่างคม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150386	2016-09-30 21:24:08
2937	ช่างฮุยเพ้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150387	2016-10-07 14:24:28
2940	ช่างอุงเพียว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150389	2016-10-01 14:56:49
2941	ช่างเอ๋-อ๊อด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15039	2016-10-01 14:49:42
2942	ช่างแอ๊ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150393	2016-10-01 14:50:46
2943	ช่างตั้ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150394	2016-10-01 14:57:32
2944	ช่างเก๋	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150395	2019-03-06 12:26:32
2945	ช่างบุญชู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150396	2016-10-11 13:59:30
2946	เทพมงคล ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150396	2023-02-07 15:49:02
2947	ช่างเล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150397	2021-11-09 16:02:51
2948	ช่างเอ๋	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150398	2016-10-11 09:39:39
2949	ช่างวิโรจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150399	2016-10-08 10:25:32
2950	ช่างเท้ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1504	2019-12-22 17:50:18
2951	ห้างทองมังกรทองเยาวราช (นายเอกกวี ชัยปภาฐกิตติ์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150401	2017-01-15 15:11:57
2952	ห้างทองชนะกิจ (นางกัญชลา สันตินิธิกุล)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150404	2017-09-30 14:47:43
2953	บริษัท ซีกวงโกลด์ จำกัด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150405	2019-12-24 16:24:10
2954	บริษัท ลุ้ยล้วง โกลด์ จำกัด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150407	2025-04-20 10:45:34
2955	ตั๊กเซ่งฮง (รัตน์)	-12140405.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150408	2019-06-12 10:00:02
2956	เยาวราชเม็งเส็ง ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150409	2016-10-18 14:35:30
2957	เยาวราชชั้น1 หนองตอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15041	2016-10-18 15:02:56
2958	เยาวราชชั้น1ศรีบุญยืน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150412	2016-12-20 09:46:35
2959	เยาวราชชั้น1จตุจักร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150413	2025-10-02 14:51:02
2960	โต๊ะกัง9 ทองสุวรรณ(กบินทร์บุรี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150414	2020-12-12 16:03:16
2961	ฉัตรสุวรรณ ตราม้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150415	2016-10-22 13:37:19
2962	ห้างเพชรทองสถาพร8 อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150416	2016-10-25 12:04:27
2963	รุ่งสถิตย์พร ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150417	2016-11-20 14:26:40
2964	ศรีเจริญ1ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150418	2025-09-21 09:56:12
2965	ศรีเจริญ2ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150419	2020-08-01 12:55:19
2966	เยาวราชเกาะเต่า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150422	2017-04-06 18:29:27
2967	ห้างทองเมืองพลอย(เนวาด้า)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150423	2016-10-26 13:49:01
2968	ชำนาญศิลป์ น่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150424	2017-01-17 19:00:50
2969	ประสงค์ดี กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150425	2025-09-20 15:21:20
2970	หงษ์มังกร เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150426	2019-05-28 18:16:21
2971	สุภาโน่ จิวเวลรี่ บางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150428	2016-10-27 15:16:35
2972	เพชรทองเยาวราชบางปู แพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150429	2016-12-07 12:43:26
2973	ทองแม่อุไร พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15043	2023-07-15 16:11:50
2974	เยาวราชโพนทอง สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150431	2024-04-28 13:40:57
2975	ศิริรุ่งแสง สำนักงานใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150432	2017-05-04 17:06:49
2976	ศิริรุ่งแสง สาขา1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150433	2017-06-23 13:54:14
2977	ศิริรุ่งแสง สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150434	2017-05-04 17:07:09
2978	ทองใบเยาวราช บ่อวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150437	2018-08-16 11:09:25
2979	เยาวราชพัฒนานิคม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150438	2017-01-10 15:48:20
2980	พรมงคล อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150439	2022-08-19 16:55:05
2981	เพชรบูรพาเยาวราช ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15044	2023-01-20 12:37:42
2982	ไทยแสงทอง บางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150441	2025-08-13 14:17:17
2983	ชานันท์เยาวราช สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150442	2019-01-09 17:26:59
2984	รุ่งเรืองเบญจพร ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150443	2016-11-20 14:45:06
2985	จิ้นเฮงหลีโกลด์กำไลหยก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150444	2019-08-22 11:22:38
2986	เยาวราชกรุงเทพเชียงกลาง น่าน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150446	2025-10-18 15:43:36
2987	แม่บังอร ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150447	2017-01-18 18:14:59
2988	ไทยมงคล หนองแขม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150448	2020-01-28 15:27:56
2989	ไทยมิตร บางพูน ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150449	2025-10-21 17:43:31
2990	ลักกี้ สะพานสูง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150453	2016-12-06 16:53:08
2991	ยูพีเยาวราช กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150453	2025-10-04 12:46:06
2992	แม่ละมัย ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150455	2024-12-22 15:21:08
2993	เรวดี สระแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150456	2025-09-13 11:21:16
2994	เยาวราชเลิงนกทา ยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150457	2021-04-03 17:36:40
2995	สินสุวรรณ7 แม่สอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150459	2025-05-21 15:31:20
2996	สุขแก้ว1 ปะทิว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15046	2022-06-26 12:29:18
2997	สุภาภรณ์ พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150461	2016-11-29 14:40:17
2998	พรภักดี พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150462	2016-11-29 14:50:44
2999	เพชรสิริ สุพรรณ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150463	2016-11-30 14:52:45
3000	ชัยเจริญ จอมทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150464	2025-01-17 16:20:50
3001	กิจเจริญ บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150465	2017-03-13 15:59:11
3002	เจริญสิน1 เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150468	2025-08-26 13:48:07
3003	ดีจริง สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150469	2020-06-19 12:55:11
3004	อุ่ยอุทัย เชียงของ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15047	2025-10-03 16:18:41
3005	แม่หล่วน8 ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150471	2016-12-03 16:26:38
3006	เอกทวี สาธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150472	2017-09-15 13:36:23
3007	ทองใบหยก สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150473	2025-04-22 16:01:46
3008	พนิดา สวนแตง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150474	2021-04-06 10:00:48
3009	เลี่ยงฮวดโกลด์สมิท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150475	2023-03-23 13:45:27
3010	เยาวราชโลตัส เกษตรวิสัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150476	2021-06-13 14:04:24
3011	ทองวิบูลย์ ป่าโมกข์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150477	2024-10-03 13:30:25
3012	ง่วนเฮงเชึยง2 พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150478	2020-12-12 16:52:23
3013	ชมพูนุท กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150479	2020-04-17 12:09:33
3014	เยาวราชหนองชาก ชลบุรึ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150482	2016-12-10 16:46:13
3015	นันทชัย บ้านดู่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150483	2017-09-15 12:47:49
3016	เยาวราชมล อู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150483	2022-07-10 10:19:24
3017	ชาตรี (หนุ่ม) อู่ทอง	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.150484	2025-10-21 17:30:34
3018	ห้างทองเยาวราชบางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150485	2016-12-13 14:35:51
3019	คุณแม่ต้อม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150486	2019-08-23 13:01:33
3020	มรกต2559 กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150487	2025-02-11 15:39:18
3021	เยาวราชนิคมพัฒนา ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150488	2018-04-04 16:48:33
3022	ม้าสุวรรณเยาวราชโกลด์สมิทธิ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150491	2025-09-11 10:47:48
3023	เคที คอร์ปอเรชั่น 2499	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150492	2018-04-07 17:29:23
3024	โต๊ะกังประชาสงเคราะห์ ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150493	2025-07-15 13:55:35
3025	ห้างทองโต๊ะกังดินแดง 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150494	2025-07-20 14:33:27
3026	โต๊ะกัง อ.อุทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150496	2022-12-27 16:24:47
3027	ทองวิเศษ(นราธิวาส)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150498	2025-09-10 15:11:01
3028	ทองสุพรรณเยาวราช4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150499	2016-12-21 14:02:58
3029	เยาวราชบางใหญ่ซิตี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1505	2020-09-15 15:09:47
3030	ควายน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150501	2016-12-31 00:14:02
3031	ยิ่งเจริญ ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150502	2018-12-26 11:39:09
3032	ทวีชัย๙ กม12	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150504	2022-01-13 17:29:01
3033	ตั้งเซ่งเฮงนิคม304 ปราจีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150505	2024-12-21 16:42:25
3034	ทองไพจิตร ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150506	2017-01-05 17:47:14
3035	มังกรทอง บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150508	2017-01-07 13:24:28
3036	กัญญารัตน์ พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150509	2019-11-23 11:40:47
3037	โต๋วจิบง้วน ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150512	2019-07-23 15:43:03
3038	อุ้ยเฮง ปทุมธานี	96.21	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150514	2018-10-26 12:06:16
3039	เยาวราช5 ประเวศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150516	2017-01-07 17:58:09
3040	กิจเจริญ บางขุนนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150517	2024-09-06 16:12:17
3041	ท.นพคุณ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150518	2025-02-11 11:18:08
3042	ทวีชัย๙ อ้อมน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15052	2017-01-10 17:04:05
3043	นำชัย นครพนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150521	2022-03-26 15:33:03
3044	ชัยเจริญ ท่าดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150522	2020-05-07 10:36:31
3045	เลี่ยงฮวด โกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150524	2018-05-25 17:45:13
3046	รักษ์ศิริ อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150525	2025-10-17 13:32:30
3047	แม่ดำ อ่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150526	2017-04-07 16:17:51
3048	รัตนาภรณ์ สุราษฎร์ธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150527	2019-12-13 16:40:12
3049	ของขวัญ เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150528	2025-10-15 15:58:52
3050	ทีแอลเอชเอสโกลด์ ประเวศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150529	2017-01-13 13:03:00
3051	ไทยสมบูรณ์ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150531	2017-09-23 14:29:29
3052	ทรัพย์ทวี ละงู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150532	2017-01-13 15:35:25
3053	กิมลั้ง ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150533	2025-04-01 15:53:48
3054	ทองดีเยาวราช เจิ้ง ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150536	2018-05-26 17:18:01
3055	ถิ่นฟุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150537	2025-09-18 11:55:18
3056	พูนศักดิ์ ชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150538	2017-01-14 17:09:38
3057	เพชรเจริญ ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150539	2017-01-15 12:55:48
3058	ทองนพคุณ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15054	2020-09-13 13:11:35
3059	ทองไท3 ปากเกร็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150541	2018-01-07 16:03:20
3060	ทองไท1999 นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150542	2018-01-21 16:43:18
3061	ทองดีเย่าวราช มาบยางพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150543	2018-11-03 15:45:35
3062	เจ๊หยก เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150544	2017-01-18 13:54:50
3063	เทพนิมิต เจ๊แดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150546	2025-01-15 08:49:05
3064	เทพนิมิต อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150547	2020-03-20 10:25:41
3065	แม่กิมเอ็ง บางระจัน	0.00	152.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150548	2025-10-19 15:19:03
3066	จงคิมเฮง ชุมพร	-639095.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150549	2025-10-26 14:02:18
3067	เซ่งหลีเฮง คลองตัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150551	2017-01-20 17:25:05
3068	เพชรทองดี5 ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150552	2023-02-23 16:13:50
3069	ตั้งเม่งเกีย ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150553	2023-12-07 10:40:45
3070	แม่วรรณี10	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150554	2020-11-24 14:36:45
3928	แม่สุพร 1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151762	2023-03-02 16:22:43
3071	ใบหยกทองทวี พิมาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150555	2018-10-27 16:09:16
3072	แม่ทองสุข โกลด์ ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150556	2020-05-05 09:03:17
3073	ง่วนเฮงเชียง1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150557	2020-12-13 08:57:19
3074	บุญวิชิต กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150558	2020-11-11 16:16:20
3075	บัวขาว ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150561	2025-07-20 14:30:37
3076	อริศรา ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150563	2017-04-18 16:56:09
3077	โต๊ะกังแม่เหียะ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150564	2025-09-13 15:01:53
3078	โชคเจริญ ประจวบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150565	2017-01-24 19:15:09
3079	แสงสุวรรณ2 มีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150566	2017-02-16 16:10:41
3080	เยาวราชทับกวาง สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150567	2025-09-27 12:32:31
3081	รัตนสุวรรณ2000 ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150568	2024-08-10 11:05:59
3082	แว่นทองพัฒนา เพชรบูรณ์	-547.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150569	2024-10-12 14:40:00
3083	แม่บุญรอด ติวานนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15057	2017-11-08 13:37:22
3084	ฮั้วเฮงล้ง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150571	2017-10-14 15:43:06
3085	เยาวราชกรุงเทพ พาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150574	2017-07-29 17:57:32
3086	แม่ทองดี กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150575	2018-02-04 12:14:33
3087	เยาวราชละอุ่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150577	2017-03-02 16:50:01
3088	ดีดีรังสิต 4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150579	2022-12-08 16:29:53
3089	ถาวร ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15058	2024-10-15 15:27:13
3090	สินทวี แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150581	2017-02-17 16:44:49
3091	ชัยสุวรรณ3 สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150582	2025-09-10 15:16:38
3092	รุ่งฟ้า (เพ็ญพร)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150583	2024-04-09 11:51:29
3093	ทองนพเก้า กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150584	2018-04-26 15:03:19
3094	มณีเพชร ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150585	2018-04-27 16:17:31
3095	สินทอง2 เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150586	2020-03-07 16:44:27
3096	ดีดีรังสิต5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150587	2025-10-02 10:09:25
3097	รุ่งโรจน์3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150588	2017-02-17 16:43:06
3098	ดีดีรังสิต2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150589	2025-06-18 10:04:38
3099	ไทยดี3 หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150592	2019-10-26 13:12:27
3100	เบ๊ย่งอัง ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150593	2022-09-06 15:57:48
3101	กุหลาบ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150594	2019-07-12 10:27:34
3102	เบ๊ย่งอันลพบุรี แม่ง้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150595	2024-02-08 15:12:47
3103	ทีเอสวาย2016มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150596	2020-07-17 13:44:32
3104	สุวรรณภูมิ เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150597	2017-05-30 16:17:41
3105	คลังทองเยาวราช ชัยทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150598	2019-03-22 15:51:08
3106	ทองสมบูรณ์เยาวราช ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150599	2020-06-30 16:34:49
3107	แสงทองใบนวนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1506	2017-09-26 14:13:50
3108	รัตนาวลี บางคอแหลม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150601	2018-07-12 17:23:44
3109	วรรณเยาวราช อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150602	2025-03-27 13:08:57
3110	พรเจริญ พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150603	2019-01-20 15:26:06
3111	ทัดทองเยาวราช ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150606	2023-03-05 11:58:38
3112	เพชรเมืองทอง พระประแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150607	2018-01-10 09:31:30
3113	รุ่งโรจน์ นครพนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150608	2025-06-13 15:40:40
3114	ศรีทองใบ สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150609	2025-06-28 16:30:33
3115	เยาวราชเพิ่มพูน2016	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15061	2017-03-05 11:45:55
3116	สินสุวรรณ4 สุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150611	2017-03-05 13:08:17
3117	สุวรรณนคร ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150614	2021-03-19 16:29:24
3118	อันเจริญ พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150615	2019-03-17 15:02:52
3119	ดีจริงเยาวราช มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150616	2025-10-26 11:49:41
3120	ศิริวรรณ แก้วอินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150618	2022-09-17 16:53:57
3121	กิมฮ้อเยาวราช ชัยภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150618	2020-01-28 11:09:19
3122	สิงห์ทอง เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15062	2017-03-10 15:25:32
3123	เพชรทองเยาวราช2555	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150623	2018-11-29 16:47:16
3124	พรพรรณเยาวราช มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150624	2018-06-24 10:56:18
3125	หลีเซ่งเฮงเยาวราช ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150625	2018-03-06 16:29:26
3126	พรสุพรรณ คลองตัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150626	2021-01-29 16:54:10
3127	เจริญวังทอง ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150627	2023-06-03 16:18:33
3128	เจริญชัยวังสมบูรณ์ สระแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150628	2021-04-02 16:30:34
3129	เจริญสิน นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15063	2024-10-10 15:35:57
3130	หนึ่งทองดี3 สมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150631	2017-03-21 15:32:07
3131	เอกทวี ร่มเกล้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150632	2024-10-22 09:54:34
3132	เสี่ยมเตี้ยง กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150633	2021-07-20 15:49:23
3133	เฮงเจริญ กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150633	2018-10-16 17:24:31
3134	ทองสุขใจ สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150634	2017-03-28 15:50:15
3135	เพชรหงษ์ทอง สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150637	2017-03-28 15:58:15
3136	ทองห้าดาว ท่าน้ำนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150638	2025-07-25 14:57:59
3137	ธัญทิพย์ มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15064	2025-03-01 12:20:33
3138	เฮงเฮงเยาวราช หนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150641	2017-03-30 17:29:02
3139	พรปิยะ หัวหมาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150642	2025-03-13 13:49:07
3140	เจริญสิน2 เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150643	2023-05-06 10:43:02
3141	ศรีเจริญ3ชลบุรี	-1923.66	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150644	2025-10-25 15:26:37
3142	ฉัตรสุวรรณตราสิงห์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150645	2017-10-25 15:09:48
3143	เยาวราชปลวกแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150646	2022-10-20 15:09:34
3144	แม่ประภัสสร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150647	2025-09-07 13:26:59
3145	ทองทองดีสระแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150649	2017-12-16 14:49:10
3146	อึ้งเฮงหลีตราประตู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15065	2017-08-08 16:46:00
3147	เลิศชัย สตูล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150653	2023-10-19 10:15:50
3148	เกียเฮง สะพานควาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150654	2017-06-07 16:13:19
3149	อินทรีทอง พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150656	2017-04-21 08:57:58
3150	ทองเดช ลำลูกกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150657	2017-04-21 15:36:52
3151	กิมย้ง สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150658	2025-10-05 11:29:22
3152	เยาวราชอ้อมใหญ่ สามพราน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150659	2018-10-20 17:26:34
3153	อึ้งเฮงหลี ตราพระ นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150661	2025-04-24 15:44:34
3154	เจ๊หงส์เยาวราช สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150662	2018-01-21 16:14:50
3155	ปางทองคำ เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150663	2018-10-31 16:29:40
3156	แม่ทองย้อย สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150664	2025-10-18 16:59:00
3157	ทองดีเยาวราช พระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150665	2024-10-08 16:55:07
3158	ศรีฟ้าดี บุคคโล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150666	2017-04-27 15:40:02
3159	ณคร บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150668	2024-06-12 16:25:25
3160	นพเก้า พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15067	2017-05-05 15:41:15
3161	ลิ้มสุวรรณ2 ดาวคะนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150671	2022-07-07 14:56:15
3162	ทวีโชค กิมเฮ็ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150672	2022-10-21 16:06:24
3163	กาลทอง จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150674	2025-06-26 14:35:23
3164	แม่ทองคำ ลำลูกกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150675	2018-03-09 16:06:32
3165	ประกายทอง จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150676	2025-10-19 08:22:20
3166	ทองเจริญ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150677	2018-02-28 14:06:19
3167	แสนสุขเยาวราช ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150678	2017-12-07 16:49:18
3168	แสงทองดี ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150679	2022-10-20 14:35:38
3169	ทองดีเยาวราช หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15068	2022-03-15 10:40:36
3170	สารภี เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150681	2024-09-24 15:45:39
3171	เพียรทิพย์ ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150684	2017-08-20 14:52:56
3172	นพคุณพิพัฒน์ นครสวรรค์	-4341105.29	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150686	2024-10-25 16:33:40
3173	ศรีกาญจนา หนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150687	2019-09-03 16:28:48
3174	เทพนิมิต หนองหาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150688	2017-09-14 16:01:49
3175	อึ้งเฮงหลี ตราเงิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150689	2018-05-09 17:35:21
3176	ทองใบเจริญ ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15069	2025-10-07 09:36:36
3177	เอเวอร์โกลด์ 88	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150692	2020-02-25 17:58:29
3178	ตั้งฟงเฟย หัวหิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150693	2017-06-08 15:11:18
3179	คุณนิธิมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150694	2017-06-12 10:30:27
3180	เอกอรินทร์ ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150695	2017-06-09 15:28:43
3181	เดือนเพ็ญ พานทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1507	2018-12-12 17:53:45
3182	ผ่านฟ้า2 ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150701	2025-09-25 13:15:12
3183	เจริญชัยปัตตานี 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150704	2018-01-12 14:09:43
3184	เจริญชัยปัตตานี 3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150705	2018-01-28 15:27:17
3185	นำชัยเยาวราช คำชะอี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150706	2024-10-09 15:17:23
3186	เกรียงเจริญ บางเสาธง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150707	2022-07-19 15:57:45
3187	ร้อยเปอร์เซ็นต์ ดาวคะนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150708	2025-05-24 14:55:15
3188	เยาวราชบ้านหมอ สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150709	2019-05-10 16:55:37
3189	ศรีกรุงชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150711	2018-08-10 16:31:13
3190	เพชรพัฒนา ชนแดน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150712	2025-08-16 10:13:36
3191	ทวีชัย๙ คลองครุ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150713	2017-07-05 13:48:04
3192	เพชรทองดี หนองไผ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150714	2025-01-18 16:16:56
3193	ทองแสงไทย เฮียเงี๊ยบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150715	2017-07-08 15:06:54
3194	ทับทิมทอง เมืองทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150716	2017-09-20 13:24:32
3195	เยาวราช กม12	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150717	2022-01-06 17:11:24
3196	ไทยยินดี1 หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150719	2018-01-06 19:59:02
3197	โอ้วซุนเซ้ง บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15072	2018-04-24 17:02:53
3198	ลำลูกกา เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150721	2018-03-12 11:45:20
3199	ซี.เค.แอนด์ ซัน เอ็นเนอร์ยี่(ประเทศไทย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150722	2017-11-22 15:33:49
3200	จงเจริญ บ้านนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150723	2023-02-12 14:25:52
3201	อุ่ยอุทัย เทิง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150724	2025-10-25 16:01:09
3202	เยาวราชดำเนินสะดวก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150725	2024-07-19 15:09:00
3203	ทองร่มเกล้า ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150726	2019-12-18 17:22:31
3204	ทวีโชค พรอมท์พอล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150727	2017-07-29 11:49:46
3205	เยาวราชเขืองใน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150728	2017-07-30 14:49:34
3206	สหยานยนต์ หาดใหญ่ สาขา1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150729	2017-07-30 14:36:32
3207	ไท้ฮั้วเฮงบางบอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150732	2025-08-06 11:05:20
3208	ทองดีเยาวราช สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150735	2019-05-12 12:00:02
3209	ชัยเจริญโกลด์ อำนาจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150736	2019-02-16 17:23:44
3210	อัมรินทร์ ละแม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150737	2025-07-20 13:28:22
3211	เนินพลับหวาน พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150738	2018-05-17 14:52:32
3212	ทองสุพรรณกิจ สองพี่น้อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15074	2025-10-05 11:08:23
3213	ราชา3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150741	2019-02-28 16:46:15
3214	พรพจน์ ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150742	2017-09-22 15:15:26
3215	สุภากาญจน์ ด่านช้าง	0.00	0.000	0.000	76.200	0.000	0.000	0.000	2025-11-20 15:38:54.150743	2025-10-22 18:02:01
3216	จังเจริญ ลพบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150744	2019-11-27 15:17:46
3217	เพชรภวัตวงศ์ คลองสามวา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150745	2025-07-30 11:20:44
3218	ทองดีเยาวราช อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150746	2017-08-19 16:45:37
3219	กานต์มณี บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150747	2022-09-04 13:28:50
3220	ไทยนิยม (นายเฮง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150749	2025-09-25 12:01:39
3221	แม่ทองทิพย์ เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150751	2018-06-09 12:12:07
3222	แม่จันทร์สม หางดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150752	2018-07-25 18:17:29
3223	มณีกาญจน์ สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150753	2018-07-24 10:23:59
3224	เจริญถาวร บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150754	2025-10-19 14:06:24
3225	ห้าดาวทองสวย หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150754	2017-08-27 12:26:06
3226	ตั้งตกเซ้ง กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150755	2018-06-23 16:24:37
3227	คู่บุญ นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150756	2021-09-19 15:19:11
3228	อัมรินทร์ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150757	2024-05-22 14:23:28
3229	อุเทน มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150759	2023-01-31 10:42:51
3230	แสงไทย ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15076	2021-02-09 16:54:29
3231	วรรธนา พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150761	2025-09-13 15:59:58
3232	ไพบูลย์2 มวกเหล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150764	2023-08-03 12:23:18
3233	เยาวราชคลอง8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150765	2025-04-04 15:52:04
3234	ไทยนิยม(เสาธง) ลพบุรี	0.00	0.000	0.000	381.150	0.000	0.000	0.000	2025-11-20 15:38:54.150766	2025-10-24 16:52:38
3235	ศรีเสาวภา ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150768	2018-02-21 17:07:34
3236	ทองอภิชาติ กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150769	2018-01-20 11:39:24
3237	เยาวราชอำนาจเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15077	2020-08-11 12:25:12
3238	จินเฮงฮวด สะพานสูง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150771	2023-05-17 14:38:32
3239	อ.รัตนะ สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150772	2019-03-10 16:23:01
3240	ราชวัตร ดุสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150773	2025-09-03 10:59:00
3241	เยาวราชภูเก็ต 1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150774	2025-03-21 14:35:05
3242	เหลี่ยงเฮง นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150775	2025-10-22 10:14:01
3243	เบสท์ ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150776	2025-10-16 17:38:10
3244	พรเจริญ บัวขาว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15078	2018-02-12 15:56:15
3245	ธงเจริญเยาวราช อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150781	2025-10-18 14:44:17
3246	เยาวราชท่าลาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150783	2019-02-28 17:12:18
3247	แม่ขจิตเยาวราช พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150783	2019-11-09 18:02:06
3248	เหลี่ยงเฮง ปากเกร็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150785	2022-07-20 12:12:38
3249	ฮ้งเซ่งเฮงเยาวราช สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150786	2018-07-04 15:25:44
3250	สินสุวรรณ 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150787	2017-10-19 10:06:21
3251	อึ้งเฮงเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150788	2024-06-29 09:07:37
3252	เบ๊เซ่งเฮง บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150789	2020-02-13 10:50:29
3253	เฮงเซ่งเฮง ชายใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15079	2023-02-09 16:04:29
3254	แม่อิ่ม2559	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150791	2019-06-12 17:10:27
3255	อั้งเซ่งเฮง ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150792	2017-10-25 13:27:29
3256	เจริญชัยสิริ มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150795	2021-08-21 16:17:39
3257	เซ่งฮงล้ง ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150796	2021-06-27 14:29:53
3258	สันกำแพง60	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150797	2024-10-31 15:21:24
3259	แม่ริม เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150798	2024-10-31 15:20:35
3260	ศรีฟ้า กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150799	2017-11-02 12:43:32
3261	อร่ามศิลป์ อ่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150801	2019-11-16 18:07:45
3262	เยาวราชภูซาง พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150816	2023-04-02 15:32:08
3263	แม่อารีย์ กาฬสินธุ์	0.00	65.500	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150817	2025-10-22 17:38:26
3264	อึ้งเซ่งเฮง ยิ่งเจริญ สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150818	2021-12-11 18:24:34
3265	ทองพัฒนา ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150819	2017-12-19 15:50:01
3266	ภูมิฐาน ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15082	2017-12-21 17:33:26
3267	คุณดี 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150821	2017-11-17 14:51:35
3268	มั่นคง มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150824	2018-01-09 16:12:17
2200	4ไถ่ มหาชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.148537	2025-11-20 15:44:27.91936
3269	มณีลักษณ์ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150825	2023-08-19 10:54:59
3270	เยาวราชบางขุนนนท์ บางกอกน้อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150826	2025-10-14 14:26:17
3271	ทองประเสริฐ์ สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150827	2022-07-29 15:24:58
3272	บ้านทอง เกาะสมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150828	2017-11-24 17:13:10
3273	ปังซุ่นเฮง สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15083	2022-10-21 16:15:59
3274	ทองดีเยาวราช สุวรรณคูหา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150831	2021-12-19 15:40:54
3275	เพชรทวี สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150832	2017-12-15 10:23:20
3276	เยาวราช อ.ม่วงสามสิบ 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150835	2020-03-13 17:26:24
3277	ทองสวย เยาวราชอุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150836	2018-03-15 16:44:40
3278	เอเอ เยาวราช บางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150838	2018-02-22 18:28:20
3279	คุณแว่น	-641417.95	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150839	2025-10-24 12:43:01
3280	ทองสวยเยาวราช กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150841	2020-01-15 17:53:16
3281	รุ่งเจริญเยาวราช กำแพงแสน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150842	2017-12-23 15:07:03
3282	แม่เงินเย็น หนองมน ฮั้วอัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150843	2018-09-25 18:18:32
3283	คุณศรีสุรีย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150844	2019-06-11 09:34:57
3284	คุณฝุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150846	2018-01-09 11:05:33
3285	คุณปราโมทย์ (เฮียจิง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150847	2025-08-26 14:29:04
3286	เยาวราชบางสะพานใหญ่ ประจวบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150848	2023-10-31 09:16:12
3287	เยาวราชอึ้งฮงเฮง ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150849	2025-09-03 10:41:36
3288	ทองธนา สี่พระยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150851	2019-11-12 15:08:11
3289	ทองดีเยาวราช สัตหีบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150852	2017-12-17 16:13:33
3290	แม่ยุพิน9	0.00	0.000	0.000	1143.350	0.000	0.000	0.000	2025-11-20 15:38:54.150853	2025-10-24 16:52:56
3291	เยาวราชคลอง16	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150854	2021-02-25 16:55:52
3292	เด่นเจริญ หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150858	2019-07-04 16:39:31
3293	ทองคำเยาวราช สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150859	2019-04-25 18:00:56
3294	เก้ามงคล รังสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15087	2023-09-22 10:34:04
3295	ทองรวยดี สามร้อยยอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150872	2025-01-07 11:42:35
3296	พัวเซ่งฮวด อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150874	2022-06-22 12:30:13
3297	เจริญมิตร อุทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150875	2018-03-27 15:42:30
3298	วัชรินทร์ทองคำ สวนหลวง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150876	2022-07-07 14:58:32
3299	ประสานศิลป์ ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150877	2023-01-15 15:51:55
3300	อึ้งเซ่งเฮง2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150878	2022-11-19 15:26:22
3301	ฮั่วเฮงเยาวราช ประชาอุทิศ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150879	2018-09-05 15:37:34
3302	เฮงเฮงพันท้าย สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150881	2023-11-13 15:33:26
3303	โชคดีเยาวราช เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150882	2025-03-04 16:43:55
3304	ฮั้งเซ่งล้ง คลองสาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150885	2021-03-10 10:35:57
3305	เยาวราช2 ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150887	2018-08-02 15:55:25
3306	เยาวราชกุดชม ยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150888	2020-08-15 16:22:43
3307	เยาวราชหนองสูง มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150889	2019-10-19 16:53:04
3308	เยาวราชทรายมูล ยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150891	2018-04-25 11:11:20
3309	ศรีรุ่งเรือง2 พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150892	2018-01-11 12:03:20
3310	พงษ์ทองดี 18	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150894	2018-01-11 15:13:02
3311	ทองโรจน์ ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150895	2020-01-21 16:06:38
3312	เยาวราชปลาปาก นครพนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150896	2022-10-15 15:49:04
3313	เยาวราชกรุงเทพ9 อำเภออาจสามารถ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150897	2018-01-13 00:00:00
3314	เสรีวัฒน์ เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150898	2022-05-11 16:25:45
3315	เมลดาเยาวราช บึงกุ่ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1509	2018-01-15 17:33:42
3316	เยาวราชเขมราฐ อุบล	-1553920.85	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150903	2025-10-11 11:59:58
3317	ชัยรุ่งเรืองเยาวราช เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150904	2019-02-14 16:43:39
3318	แสงไทย5 ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150905	2018-07-14 16:29:47
3319	เยาวราชอยุธยา1999 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150906	2018-01-17 15:40:30
3320	เพชรสุวรรณ ตรามังกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150907	2018-01-17 14:59:50
3321	ทองเจริญ คำตากล้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150908	2019-04-04 18:08:14
3322	เยาวราชคำตากล้า สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150909	2019-12-18 17:17:51
3323	ฟ้าประทาน สุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150911	2018-01-20 11:10:01
3324	เฮงตระกูล นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150912	2021-06-05 13:59:08
3325	เทพประทาน กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150913	2025-10-18 14:32:30
3326	ทองดีเยาวราช เจริญศิลป์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150914	2018-01-21 16:14:16
3327	ศรีสุพรรณ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150915	2018-01-20 12:57:30
3328	สุธาดา สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150918	2025-10-26 14:19:33
3329	ทองปัญญากรุ๊ป ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150919	2019-01-26 16:34:12
3330	ทองปัญญา5 ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15092	2018-04-08 16:04:12
3331	มณฑา แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150921	2019-04-11 15:05:30
3332	ตั้งเฮงเฮง สาขา5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150922	2022-11-05 17:18:27
3333	เยาวราชเชียงใหม่ 2016	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150923	2018-04-26 17:33:16
3334	ทองสุพรรณ ท่าพี่เลี้ยง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150924	2018-01-24 13:29:24
3335	แม่เสงี่ยม อุทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150926	2023-01-26 16:25:05
3336	แม่เส่ง2 แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150927	2025-03-21 15:56:23
3337	กวนอิมเยาวราช ตลาดแกรนด์ อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150928	2018-01-30 18:16:32
3338	ทองดีเยาวราช ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150929	2022-07-27 16:34:14
3339	ซิลเซี่ยโกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150931	2025-03-18 10:59:43
3340	อึ้งเซ่งเฮง3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150933	2018-11-17 17:39:32
3341	แม่เง็กเน้ย ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150936	2018-02-03 14:50:43
3342	ทรัพย์เจริญ บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150937	2023-11-23 14:52:58
3343	กรุงเทพ สายสี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150938	2025-04-20 14:33:55
3344	ทับกวาง สุวรรณเกลียวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150939	2025-10-09 13:42:55
3345	เยาวราชภูเก็ต2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150941	2020-06-23 14:01:44
3346	ทรัพย์อนันต์ อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150942	2020-10-25 14:28:08
3347	เฮงเฮงโกลด์ ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150943	2020-01-15 16:38:43
3348	พงษ์ศักดิ์ นางรอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150944	2019-11-16 17:48:20
3349	เฮงเจริญ จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150946	2018-08-11 16:02:48
3350	รุ่งทองใบ สาธุประดิษฐ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150947	2025-08-21 14:46:13
3351	จอมทอง เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150948	2019-01-18 10:55:21
3352	รัตนไชย กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150949	2023-01-20 16:12:29
3353	กนกลักษณ์ ดุสิต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150952	2018-06-09 13:04:17
3354	ธนาภรณ์ จิวเวอร์รี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150953	2018-12-27 18:01:38
3355	เยาวราชวัดกำแพง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150954	2019-05-03 16:38:18
3356	กาญจนาภิเษก อมตะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150955	2018-03-09 17:07:44
3357	สุเมธ หนองแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150956	2024-12-25 15:52:26
3358	ยิ่งเจริญ สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150958	2018-04-02 14:58:56
3359	เยาวราช อ.ม่วงสามสิบ สาขา2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150959	2020-09-16 09:04:37
3360	เฮงทวี สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15096	2018-05-06 14:39:12
3361	เยาวราชนครนายก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150962	2023-03-03 11:28:08
3362	ชัยเจริญ ตรอกจันทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150963	2023-09-16 16:57:37
3363	ทองไพรัตน์ อุตรดิตถ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150964	2018-03-24 12:50:28
3364	ทองประดิษฐ์ ปากน้ำ ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150966	2025-01-19 12:11:39
3365	ยงดี1 พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150968	2025-10-14 10:09:05
3366	ราชา4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150969	2019-02-28 16:49:21
3367	รุ่งเรืองทรัพย์พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15097	2022-12-04 16:23:46
3368	สิริลักษณ์ ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150971	2018-07-18 14:03:57
3369	จักรพรรดิ์ เยาวราชขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150972	2025-10-25 14:28:08
3370	ชัยเจริญ สุรินทร์2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150973	2020-08-02 15:58:23
3371	ชัยเจริญ1 สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150976	2025-06-25 12:45:39
3372	ไทยนิยม พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150977	2018-04-03 17:29:01
3373	อารยา1 อ.เมือง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150978	2018-06-29 16:46:15
3374	เจริญเยาวราช365 ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150979	2018-04-06 19:00:58
3375	เจริญศิลป์ เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15098	2018-04-07 18:22:10
3376	ทองเอก อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150982	2019-01-04 13:43:32
3377	ยิ่งเจริญ ตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150986	2025-08-08 15:44:42
3378	ทองดีเยาวราช บ้านค่าย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150987	2018-04-25 14:16:53
3379	เอสศิริโกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150988	2018-04-25 13:49:56
3380	มิตรมงคล ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150989	2022-10-19 00:00:00
3381	รัตนา จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15099	2018-10-24 16:49:50
3382	จันทร์เจริญ จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150992	2024-02-22 10:59:15
3383	ไทยสวัสดิ์ พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150993	2023-02-16 15:26:44
3384	จงฮั่วเฮงเยาวราช ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150994	2025-10-22 13:19:20
3385	กรชวัล พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150995	2018-05-04 16:03:37
3386	เยาวราช1 ยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150996	2019-06-11 10:59:23
3387	ห้าดาว 2 หนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150997	2018-05-09 17:20:21
3388	ราชาเยาวราช ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.150998	2024-05-08 14:11:34
3389	ยิ่งเฮงสกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151	2023-11-03 16:53:49
3390	เจ้าสัว เยาวราช	0.00	51.550	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151001	2021-02-09 18:13:03
3391	โต๊ะกังสาย2 บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151002	2020-06-11 17:49:31
3392	ทองดีเยาวราช18	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151003	2019-02-16 17:24:29
3393	เยาวราชตลาดมีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151004	2022-11-22 15:28:57
3394	นำศิริ บ่อวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151005	2025-03-29 11:40:59
3395	ราชาเยาวราช เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151006	2020-08-20 14:42:59
3396	ทองชั่ง แกลง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151008	2024-07-21 11:15:01
3397	กิมเล่งเฮง4 ลำลูกกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151009	2025-09-05 14:41:25
3398	เค ที โกลด์ ลำลูกกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15101	2020-06-05 16:48:08
3399	ทองให้คุณ สนญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151011	2018-08-09 12:02:10
3400	ทองนพเก้า เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151012	2020-02-12 16:16:39
3401	ทรัพย์อนันต์ ปาดังเบซาร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151014	2019-10-12 16:59:58
3402	เยาวราชสกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151015	2018-06-03 11:33:14
3403	ตั๊งเฮงหลี ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151018	2018-09-05 17:33:50
3404	แม่จ๋า ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151019	2018-06-07 10:25:01
3405	เจ้าสัว งามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15102	2018-08-30 17:50:56
3406	แม่ทองใบ คลาสสิก บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151021	2019-10-31 10:10:09
3407	ทรัพย์ตันทอง ตาขุน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151022	2025-09-18 15:16:28
3408	นาทีทอง5 กำแพงเพชร	-1662.75	50.250	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151023	2024-03-21 10:24:42
3409	พาราโกลด์สมิธ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151024	2018-06-13 11:19:50
3410	ทวีทอง นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151025	2023-06-21 15:14:55
3411	จักรวาล ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151027	2019-11-30 00:00:00
3412	โชคทองใบ นนทบุรี	-674.00	76.250	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151028	2025-10-02 15:34:47
3413	ชลดา เยาวราช 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15103	2024-12-20 16:06:00
3414	เยาวราชหางดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151031	2019-04-11 15:13:26
3415	ศรีสุพรรณ ศรีเทพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151032	2018-06-30 17:07:14
3416	พรเจริญ3 มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151033	2021-01-08 15:16:37
3417	บ้านทอง แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151035	2025-10-22 10:43:40
3418	หลีเต้ง ตะกั่วป่า	60.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151036	2024-10-09 11:04:15
3419	บุญวิชิตเยาวราช หนองจอก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151037	2018-07-18 17:11:42
3420	คุณดวงกมล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151038	2018-08-03 13:07:58
3421	ทองนวลจันทร์ พังงา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151038	2025-04-29 12:01:50
3422	เบลล์ ญาติซ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151039	2018-10-30 10:55:12
3423	กรุณาเยาวราชปากช่อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15104	2018-07-22 15:10:43
3424	เยาวราชพระรามสี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151041	2020-12-29 16:36:28
3425	คุณเบสท์ ญาติซ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151046	2018-09-14 15:37:24
3426	คุณคมสัน 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151047	2024-11-24 15:34:44
3427	พรทองใบ บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151048	2025-07-24 13:30:28
3428	เยาวราชมาบอำมฤต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151049	2019-01-18 15:40:35
3429	อาเธอร์โกลด์ สายไหม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15105	2024-05-22 15:14:55
3430	คุณต้อมMC	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151051	2019-07-03 10:37:50
3431	คุณตุ้ม ดนุญา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151052	2023-07-13 11:27:36
3432	เอกลักษณ์โกลด์ อุตรดิตถ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151053	2025-08-29 10:28:06
3433	เยาวราชศรีปทุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151054	2024-05-08 08:45:00
3434	คุณฟ้าหยก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151055	2020-11-11 09:47:46
3435	สวิส อุดรธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151058	2019-07-09 16:13:20
3436	ลี่เฮงเยาวราช ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151059	2025-07-20 14:32:09
3437	ทรัพย์สะพาน4 เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151061	2025-10-22 14:45:31
3438	บุญสวัสดิ์ บางซื่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151062	2018-09-26 10:26:40
3439	บุญสวัสดิ์2561 บางซื่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151063	2018-08-19 11:34:07
3440	บอส ญาติซ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151064	2020-03-13 12:31:14
3441	ย่งเฮงเยาวราช สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151065	2018-08-23 17:34:08
3442	เยาวราชบางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151066	2025-05-10 13:03:01
3443	มังกรทองเยาวราช พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151067	2018-08-29 15:28:40
3444	ดาวเด่น สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151067	2024-09-13 13:30:14
3445	นพคุณ มาบอำมฤต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151069	2022-12-24 16:21:07
3446	ทองบุญวิชิต มะขามเตี้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15107	2018-11-01 17:48:48
3447	สยามโต๊ะกัง กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151071	2019-01-29 14:48:10
3448	ชลไพบูลย์ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151072	2018-09-06 17:44:11
3449	MC อ๊อด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151075	2018-09-11 11:31:16
3450	เยาวราชเสริมไทย มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151077	2018-09-12 15:06:36
3451	กรุงเทพบิ๊กซี สุวรรณภูมิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151078	2018-09-12 15:19:13
3452	ศิริทองดี นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151079	2025-09-05 11:45:50
3453	รุ่งเจริญโกลด์สมิธ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15108	2019-08-24 15:10:39
3454	คุณอำพล เจริญชีวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151081	2018-09-21 09:21:25
3455	ไทยทวี2 บางแก้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151082	2021-12-14 14:45:44
3456	ทองพิเศษ บึงกาฬ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151083	2018-11-22 16:31:48
3457	กิมเล้งเยาวราช ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151084	2024-08-14 16:37:18
3458	ทับทองเยาวราช ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151085	2025-03-22 16:13:25
3459	เมืองทองเยาวราช พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151086	2018-10-11 13:55:15
3460	แม่สถิตย์ ด่านช้าง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151087	2025-09-28 11:38:59
3461	ยินดี2 มีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151089	2024-11-22 12:22:37
3462	แม่จรินทร์ 2 สัตหีบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151091	2025-10-21 14:46:50
3463	สหพัฒน์ ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151153	2025-10-02 13:20:09
3464	มามาโกลด์ กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151154	2018-10-20 17:00:14
3465	เยาวราช มวกเหล็ก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151155	2018-10-25 15:13:13
3466	คุณตี๋ ญาติซ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151158	2025-10-24 11:45:11
3467	สุวณี บางพลัด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151159	2025-03-18 16:50:32
3468	แม่อิ่ม2 สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15116	2018-11-06 16:53:06
3469	เยาวราช5ดาว ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151161	2020-02-27 16:48:32
3470	ส.นำชัย3 พรหมคีรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151162	2018-11-16 13:31:37
3471	ตราดาว สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151163	2019-06-26 16:24:05
3472	ทวีโชค99 ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151164	2022-03-25 15:40:55
3473	ทรัพย์ไพบูลย์เยาวราช หนองบัวลำภู	-1090317.46	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151167	2025-10-24 12:47:02
3474	เยาวราชมหาสิน3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151168	2018-11-21 17:53:10
3475	ทองดีเยาวราชโป่งสะเก็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151169	2022-12-23 16:22:11
3476	นำโชค เซกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15117	2018-11-28 14:46:15
3477	เตี่ยจง ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151171	2019-01-10 16:37:53
3478	ทองนิพล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151172	2018-12-06 18:55:03
3479	เจริญทอง เจ อาร์ ที่ ซี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151173	2021-02-20 15:44:42
3480	ทริปเปิ้ล เอ็ม จิวเวลรี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151175	2019-07-02 17:06:33
3481	โชติสหสิน 2018 โพธิ์ไทร	-437.21	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151176	2021-04-08 11:11:40
3482	นพดล กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151177	2020-03-07 16:44:45
3483	ลูกสาวนาทีทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151178	2019-05-22 16:13:01
3484	แม่วรรณี 3 ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151179	2020-01-14 18:31:13
3485	ดีดีเยาวราช เชียงคาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15118	2018-12-16 09:59:46
3486	ศรีสมบูรณ์ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151182	2025-10-21 14:15:08
3487	ณคร ทวีกิจ บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151183	2018-12-16 17:19:14
3488	โกก้าย โกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151184	2019-03-16 16:40:06
3489	คุณอุ้ย	-24000000.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151185	2025-10-22 17:32:45
3490	เยาวราชโป่งไผ่ 2 ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151186	2019-01-08 18:24:11
3491	ไทยทวี1 ปากพะยูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151187	2018-12-22 12:49:10
3492	แม่อรุณ ตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151188	2025-06-11 15:06:17
3493	เยาวราชบางขุนเทียน แสมดำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151189	2019-10-19 17:12:24
3494	ทรัพย์มั่งคั่ง หาดใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15119	2025-07-17 13:08:20
3495	กะรัตเยาวราช สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151191	2021-10-20 17:05:05
3496	ตั้งสมบูรณ์สุข มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151192	2025-08-13 09:46:20
3497	ตั้งสมบูรณ์สุข 8 มหาสารคาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151193	2021-03-26 15:54:45
3498	โกลด์เด้นแซนด์ ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151197	2019-01-12 15:57:55
3499	อังคณา กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151198	2024-10-24 14:43:01
3500	สุภาภรณ์ สุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151199	2024-03-17 15:02:49
3501	กิมหลีโกลด์ พระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1512	2025-10-26 13:38:53
3502	ทองนพรัตน์ น้ำปาด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151201	2025-05-10 14:31:04
3503	สถาพร โกลด์2558 สุพรรณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151202	2024-11-24 15:41:10
3504	สถาพรสุขทวี กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151203	2025-09-30 17:26:51
3505	ทองนัยลักษณ์ นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151204	2020-08-15 14:32:30
3506	ทองยงดี ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151205	2022-05-26 15:10:00
3507	เบญจวรรณ168 ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151206	2019-03-19 17:29:48
3508	ร่มจันทร์ เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151207	2021-11-23 14:13:25
3509	แม่มันทนา ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151208	2019-05-24 17:07:54
3510	สิริจินดา จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151211	2025-06-05 12:22:54
3511	เปรมศิริ สามพราน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151212	2022-08-10 16:15:00
3512	เคทูเอ็นโกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151213	2019-03-06 16:24:19
3513	ทองแม่วรรณี11 ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151214	2023-04-21 16:56:29
3514	จิบฮั้วเฮง นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151215	2024-03-15 13:27:15
3515	ชัยเจริญ สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151215	2019-02-17 15:34:03
3516	แม่กานดา นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151217	2019-02-23 16:02:38
3517	พรประเสริฐ พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151218	2019-02-23 15:11:50
3518	24 กะรัต แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151219	2019-10-06 10:43:30
3519	ทองดี จอมบึง	0.00	0.000	0.000	457.300	0.000	0.000	0.000	2025-11-20 15:38:54.151221	2025-10-08 13:59:22
3520	ดูโกลด์ ท่าเรือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151222	2019-02-26 17:33:53
3521	วิวัฒน์กิจ1 สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151223	2019-03-01 16:41:22
3522	เยาวราชชั้น1 บ้านแซม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151225	2019-10-12 16:07:20
3523	ซิมเฮงหลี นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151226	2020-11-28 16:35:45
3524	โกลด์เนเจอร์ เยาวราช นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151227	2021-06-04 15:14:12
3525	เบลโลน่าโกลด์ เกาะพะงัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151228	2025-07-15 16:06:10
3526	วังทองสร้อย ทุ่งสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151229	2024-02-23 16:09:00
3527	มาบตาพุดเยาวราช ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15123	2019-04-06 15:29:38
3528	เจ้าสัว นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151231	2019-03-09 16:32:59
3529	โง้วซุ่นฮั้ว ปากน้ำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151233	2025-02-13 16:06:40
3530	ตั้งเซ่งเฮง นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151235	2021-07-03 14:16:38
3531	สำรวย ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151236	2019-03-13 15:55:59
3532	เจริญเยาวราชกุดดินจี่ หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151237	2019-05-30 17:48:14
3533	เยาวราชทรัพย์เพิ่มพูน สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151238	2019-03-20 17:20:32
3534	ทองวันดี ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151241	2022-03-17 16:39:07
3535	แม่มนตรี สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151242	2023-07-21 13:44:07
3536	100%บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151243	2020-02-21 15:40:48
3537	ซินอึ้งเฮงหลี ตราประตูชุมพล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151244	2019-06-25 18:04:54
3538	อัศวทองคำสมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151245	2023-08-24 17:23:38
3539	ไชยกำธร2เถิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151246	2019-08-17 16:41:25
3540	ดุจมิตร อู่ทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151247	2020-10-07 12:23:07
3541	เยาวราชดีดีดี งามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151248	2025-09-25 13:12:51
3542	เยาวราชเฮงเฮงเฮง งามวงศ์วาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151249	2025-06-18 14:26:18
3543	แสงนภา เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151251	2019-04-11 15:13:21
3544	เยาวราชวารุณี เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151252	2022-01-21 11:21:08
3545	โชคดี ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151253	2022-01-22 15:12:31
3546	แสงทอง สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151255	2022-02-27 15:37:30
3548	สุริยะ1 เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151259	2024-07-07 09:53:25
3549	เจริญทรัพย์ไพบูลย์เยาวราช หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15126	2024-11-30 10:08:45
3550	แม่กิมเตียงเยาวราช ตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151261	2019-05-10 13:42:32
3551	จริงใจ สงขลา	-67137.59	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151262	2025-10-26 14:14:26
3552	แพนด้า เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151263	2019-05-07 12:24:53
3553	ทวีชัย4 นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151264	2021-05-07 15:36:27
3554	อู่เงินอู่ทอง นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151265	2019-06-14 16:41:15
3555	อุดมชัยเยาวราช บางนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151266	2019-05-23 15:39:33
3556	แม่กิมไล้2 อุดมสุข	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151267	2019-05-25 16:40:36
3557	ลายไท อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151268	2019-06-10 16:18:40
3558	เพชรรัตน์ 101	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151271	2024-07-31 12:42:07
3559	ฮาบเฮง2 ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151272	2019-06-19 16:16:30
3560	เยาวราชขุนยวม แม่ฮ่องสอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151273	2019-06-23 14:43:23
3561	หลักเฮง สุกพันธ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151274	2019-09-04 11:13:22
3562	แม่รุจี หนองแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151276	2022-03-11 09:25:35
3563	งามจริงจริง เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151277	2019-06-26 15:10:46
3564	เอสดับบลิวเจมส์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151278	2023-12-09 15:41:48
3565	มณีรัตน์ ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151279	2019-10-05 11:44:42
3566	มุกมงคล ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151281	2025-10-25 16:54:42
3567	ธัญทิพย์2 มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151282	2024-09-03 11:48:42
3568	วิบูล บางกะปิ.	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151283	2019-06-30 14:39:11
3569	ศรีเยาวราช9 บางปะกง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151284	2019-08-23 16:17:37
3570	ทองสุวรรณภูมิ3 ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151287	2025-01-22 15:56:02
3571	กนกกาญจน์ นครนายก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151288	2021-05-15 11:17:20
3572	เยาวราชมังกร9 พระราม1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151289	2022-08-09 13:01:41
3573	กรทองโกลด์ สายไหม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15129	2019-09-07 15:53:39
3574	ทองอนันต์ อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151291	2022-06-02 15:55:36
3575	พรทิพย์ กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151292	2024-07-26 16:16:39
3576	พรสวัสดิ์ คลองสาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151293	2019-07-20 16:33:14
3577	เยาวราชอำนาจเจริญ 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151294	2020-02-23 11:32:19
3578	ธวัชดินแดงโกลด์ ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151296	2020-01-30 17:45:43
3579	ศรีสุพรรณ คลองเตย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151297	2019-08-08 18:39:42
3580	ทองสวยเยาวราช มุกดาหาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151298	2021-04-01 11:03:48
3581	อึ้งเซ่งเฮงโกลด์ โคกหล่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151299	2025-10-05 12:19:45
3582	อึ้งเซ่งเฮงโกลด์ ห้วยยอด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151301	2025-10-05 12:11:25
3583	เซ่งเฮงล้ง อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151303	2019-08-14 17:18:48
3584	แจน ลิ้มจิงเฮียง	0.00	0.000	0.000	304.900	0.000	0.000	0.000	2025-11-20 15:38:54.151304	2025-10-21 17:22:31
3585	เยาวราชโชคชัย 4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151305	2023-10-26 13:30:02
3586	เจริญชัย2 สำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151306	2024-04-04 14:13:46
3587	เยาวราชธนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151308	2021-02-09 17:22:07
3588	เจเอ็นเอช โกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151309	2019-09-27 14:25:07
3589	คงสุข จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15131	2025-06-05 13:07:52
3590	ธัญภรณ์ จันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151311	2025-06-05 09:50:11
3591	โรงรับจำนำบุหงาสมเด็จ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151312	2019-10-06 11:47:42
3592	เคงยวนทอง (แหลมทอง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151313	2022-12-02 12:07:03
3593	ทองฉัตร ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151315	2022-10-07 15:13:08
3594	ธนสิน ทรัพย์ทวี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151318	2019-10-19 15:42:32
3595	แม่ยุพิน สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151319	2019-10-19 09:53:07
3596	ไชยกำธร3 ลำปาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151321	2019-10-19 16:50:23
3597	ทองบางลี่ สุพรรณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151322	2022-02-20 14:53:14
3598	ธัญญ์ฐิตา อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151323	2024-06-11 14:31:10
3599	สำเภามังกรทอง นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151324	2022-06-04 13:11:13
3600	อมรณ์พัฒน์ หนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151325	2024-06-18 16:28:59
3601	เทพพิทักษ์ 5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151326	2023-10-03 15:02:22
3602	เพชรมังกร แพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151327	2019-12-19 16:08:31
3603	ป.นิธิสุวรรณ ท่าพระ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151328	2019-11-24 14:34:09
3604	จริยา ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151329	2025-05-21 11:31:59
3605	เพชรทองดี สะพาน4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15133	2019-11-23 15:13:00
3606	เวรี่โกลด์ หนองแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151333	2024-09-21 15:17:39
3607	สุพินดา ญาติซ้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151334	2019-12-18 10:29:59
3608	ก.แสงทอง กระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151335	2024-07-26 16:30:07
3609	เยาวราช๑ (ปากร่วม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151336	2023-03-14 11:06:09
3610	เต็กกิ้ม ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151337	2023-11-24 16:00:44
3611	เต็กกิ้ม 2 ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151339	2021-03-20 16:40:33
3612	ทองดีเยาวราช สะพานสี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15134	2021-12-24 16:49:59
3613	หงส์มังกรเพชร สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151341	2021-04-10 17:37:16
3614	ตั้งเฮง หนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151342	2020-02-09 15:12:40
3615	ทองดีเลิศ สมุทรปราการ	-16419.00	148.200	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151343	2025-10-19 14:47:54
3616	โกลด์ไชน์ นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151343	2022-02-24 16:41:56
3617	อิง อิง สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151344	2021-02-15 16:47:33
3618	รุ่งเรือง 2019 อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151347	2023-10-20 12:34:13
3619	โต๊ะทองคำ สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151348	2021-03-20 18:06:10
3620	ทองอันดับ1 บางปู	-43063.00	386.450	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151349	2025-10-19 14:54:39
3621	เซ่งฮวดเยาวราช อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15135	2023-08-09 15:37:30
3622	ภัทรกาญจน์ ท่าม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151351	2020-12-19 12:56:10
3623	เจ้าสัวสุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151352	2020-01-22 17:56:00
3624	ไท้เชียงฮั้ว ลาดพร้าว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151353	2020-01-28 17:12:39
3625	ไรซิ่งซัน 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151355	2025-10-07 14:59:01
3626	*เยาวราชโรจนะ อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151356	2020-07-22 00:00:00
3627	แสงเยาวราช สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151357	2020-06-18 11:51:25
3628	เพชรกะรัต ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151358	2020-02-06 14:06:54
3629	กุ๊กไก่เยาวราช บุรีรัมย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151359	2024-09-03 16:04:26
3630	ค้ำคูณ อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151361	2020-02-14 16:51:00
3631	ทองสามัคคี นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151363	2020-04-08 17:34:24
3632	เยาวราชบ้านเหลื่อม นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151365	2020-02-19 17:26:33
3633	พลอยกนก สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151366	2021-02-02 15:32:31
3634	แม่กิมถัง ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151367	2020-02-23 11:55:12
3635	ไทยมิตรลาดสวาย ปทุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151369	2020-09-09 08:51:00
3636	รัตน์(สวนมะลิ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15137	2020-04-10 18:17:56
3637	ใจดี อรัญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151371	2021-06-25 15:27:28
3638	ใจดี นนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151372	2024-06-14 15:06:53
3639	นิตเทียน ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151373	2020-03-10 08:42:22
3640	สุขสมบูรณ์ เชียงราย	0.00	95.100	0.000	76.200	0.000	0.000	0.000	2025-11-20 15:38:54.151374	2025-10-19 15:14:24
3641	ก. ศิริสุข	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151376	2025-03-15 15:38:16
3642	เยาวราชทอง555 บางปู	-18206.00	161.500	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151377	2025-10-19 14:52:55
3643	ไท้เส็งเฮง กาญจนา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15138	2024-04-20 16:39:39
3644	คุณไช้ ญาติรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151381	2020-10-06 14:54:53
3645	ทองประอร บางจาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151382	2025-10-21 16:53:14
3646	แม่กิมเตียง2 ตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151383	2025-06-01 14:12:27
3647	คุณน่อย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151384	2020-05-19 12:57:02
3648	เที่ยงธรรม บางกะปิ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151385	2022-12-21 10:16:31
3649	คุณเจษฎา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151386	2020-04-28 09:15:56
3650	ไท้หลีเฮง ศรีนครินทร์ (พี่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151388	2020-04-24 14:09:13
3651	ไท้หลีเฮง ราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151389	2025-09-24 16:22:05
3652	คุณเยาวพา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15139	2022-07-20 15:53:32
3653	ทองสยาม เลย 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151391	2020-05-02 09:21:05
3654	สมบูรณ์พานิช2 เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151392	2020-05-03 08:56:00
3655	คุณยู้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151395	2023-10-05 13:23:56
3656	100%ตลาดลูกแก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151396	2024-02-20 11:31:06
3657	สว่างอารมณ์ อุทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151399	2025-10-19 14:13:58
3658	เฮงทวีทองคำ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1514	2020-05-23 16:29:11
3659	จงเซ่งเฮงเยาวราช ชุมพร	100000.00	0.000	0.000	457.300	0.000	0.000	0.000	2025-11-20 15:38:54.151401	2025-10-16 14:40:02
3660	เพชรรัตน์ 101สาขา2	89309.68	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151402	2021-08-18 16:10:03
3661	ทรัพย์เจริญกาญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151403	2025-06-21 11:16:42
3662	กิจสุวรรณ(พญาเม็งราย สาขา2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151404	2021-02-27 16:47:39
3663	แม่กิมเอ็งบางระจัน 2020	0.00	520.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151405	2025-10-26 13:52:01
3664	ไท้เซ่งล้ง ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151406	2020-06-05 15:23:46
3665	เยาวราช7 คุ้มเกล้า	-2013.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151408	2025-07-26 15:33:11
3666	เหลี่ยงเฮง บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151409	2025-10-21 11:17:30
3667	แม่กิมเตียง5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151414	2020-06-21 15:13:19
3668	แม่ทองสุก อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151415	2021-03-24 17:21:24
3669	เจริญชัย ยโสธร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151416	2022-01-18 17:10:49
3670	รุ่งโรจน์เยาวราช ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151417	2022-01-08 17:33:30
3671	เยาวราชเพิ่มพูน สะแกงาม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151418	2021-05-28 15:40:53
3672	สยามโกลด์ เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151419	2025-09-30 14:16:25
3673	หงส์ทอง นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15142	2022-03-26 10:26:57
3674	เลี่ยงฮวด8 (ซังกรุ๊ป)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151421	2020-07-15 11:40:11
3675	เยาวราชบ้านลาน นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151422	2025-10-19 13:02:10
3676	สุวรรณกุญชรเยาวราช เชียงใหม่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151423	2020-09-26 15:06:25
3677	ทวีโชค 888	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151424	2024-05-15 12:07:32
3678	100% โชคชัย4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151425	2020-08-11 18:08:46
3679	ใจดี ตลาดยิ่งเจริญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151428	2022-11-08 09:31:57
3680	ภูเก็ตรุ่งเรืองทรัพย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151429	2022-12-06 16:44:50
3681	ทองใบ1 (ลูกชาย) พระประแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15143	2022-03-16 11:05:58
3682	เฮงถาวร ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151431	2023-04-06 12:26:12
3683	ไทยสวัสดิ์ เชียงใหม่2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151432	2025-07-05 14:02:13
3684	แม่วรรณี 6	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151433	2020-09-15 16:33:49
3685	เยาวราชธุรกิจ 9999 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151434	2022-08-11 15:06:19
3686	รุ่งทรัพย์ ตลาดหัวรอ อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151435	2025-10-26 14:12:57
3687	พรหมประทาน สมุทรปราการ	0.00	39.550	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151436	2025-10-01 15:58:23
3688	ดำรงค์ชัยสำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151437	2025-10-04 14:37:21
3689	ทองซากุระ อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15144	2022-03-15 16:24:26
3690	กนกกุล บางปะอิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151441	2025-06-14 15:42:30
3691	กนกทิพย์ ทุ่งสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151443	2023-06-01 15:04:06
3692	จิราพร นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151444	2024-12-18 16:32:38
3693	แม่ดวงพร ลำทับ กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151445	2023-06-09 14:08:30
3694	เยาวราชแม่ฮ่องสอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151446	2025-08-16 10:57:56
3695	คุณเปา 825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151447	2021-07-21 09:41:25
3696	โต๊ะกังกรุงเทพสุทธิสาร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151448	2025-10-21 17:13:00
3697	เยาวราชเก้าเลี้ยว นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151449	2022-08-26 15:26:14
3698	ศิริเมืองทอง ขุนหาญ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15145	2023-05-30 12:08:42
3699	ชำนาญกิจ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151451	2023-03-28 15:37:24
3700	เยาวราชลำนารายณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151452	2025-10-03 15:12:53
3701	จินตนา2559 อยุธยา	-98746.37	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151453	2025-10-26 12:20:05
3702	เยาวราช 18 คอร์ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151454	2025-10-21 14:26:46
3703	กรุงเทพเยาวราชอนุสาวรีย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151456	2022-03-18 09:22:18
3704	คุณนิด เพื่อนรัตน์825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151457	2021-10-06 14:07:25
3705	ศรีทอง(เดอะมอลล์ท่าพระ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151459	2021-12-08 17:29:31
3706	คุณรัตติกร ญาติคุณแจง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15146	2024-02-18 15:32:24
3707	เว่งเฮง ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151461	2022-05-17 17:01:31
3708	ชัยธานี2 (เจียระสุวรรณ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151462	2025-08-08 15:10:49
3709	ศิริมงคล สนามชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151463	2020-12-15 10:00:45
3710	ทองแท้เยาวราช แก้งคร้อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151464	2025-09-13 11:16:13
3711	เยาวราช6 บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151465	2022-01-29 16:06:48
3712	แม่สุพรรณิการ์ ตาก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151466	2020-12-30 15:07:47
3713	ลักกี้ หมู่บ้านนักกีฬา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151467	2021-01-21 15:51:02
3714	ทองหน้าร้านยุบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151469	2021-01-28 11:59:10
3715	เศษทองหลอม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151471	2021-01-28 11:59:45
3716	กาญจนกิจ2 (2)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151472	2021-02-02 11:34:58
3717	เยาวราชนิคม สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151475	2025-09-10 12:43:06
3718	ไทยรุ่งเฮง นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151476	2025-10-25 14:51:25
3719	ลิ้มอุดมชัย สุพรรณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151477	2021-05-19 09:51:53
3720	เพชรถาวร2 เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151479	2021-02-17 16:05:48
3721	ทองชัยโรจน์ แม่สาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15148	2025-10-21 11:39:24
3722	มุสลีมะฮ์ ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151481	2021-02-18 12:58:36
3723	ล้านเมือง เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151482	2025-10-21 10:40:12
3724	แม่จินดา เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151483	2021-02-27 10:02:19
3725	รัตนา นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151484	2021-02-26 13:49:55
3726	ทองลาภเจริญ พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151485	2024-11-27 13:49:43
3727	กาญจนกิจ 1	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151487	2021-05-19 10:10:17
3728	พนักงาน กุ้ง	975.00	0.000	0.000	3.800	0.000	0.000	0.000	2025-11-20 15:38:54.151488	2025-10-26 09:21:49
3729	พนักงาน ก้อย	4515.00	0.000	0.000	5.800	0.000	0.000	0.000	2025-11-20 15:38:54.15149	2025-09-27 08:45:08
3730	คุณสุเทพ (เพื่อนกิ้มฉุ่งเฮง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151491	2021-05-27 13:31:01
3731	ศรสุวรรณ ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151492	2024-09-26 13:58:22
3732	หลูชั้งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151492	2025-09-23 11:01:04
3733	จารุวัฒน์ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151493	2021-12-22 15:11:41
3734	สหไพศาล ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151494	2022-12-14 16:01:43
3735	คุณณัฐพลิน (ฝง น้องหย่ง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151495	2021-03-04 11:17:17
3736	โชคไพศาล (ยิ้ม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151496	2023-01-14 16:21:34
3737	รุ่งเจริญเยาวราช บางปูนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151497	2022-02-15 16:47:25
3738	กิจเจริญ นครศรีธรรมราช	0.00	86.800	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151498	2021-11-05 16:24:27
3739	มหานคร 168 นครปฐม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151501	2021-03-18 15:52:41
3740	ทรัพย์ทวี2 บ้านเหนือ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151502	2021-03-19 14:13:44
3741	จินฮั้วเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151503	2025-10-25 15:06:56
3742	บริษัทนำเข้า 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151505	2025-11-20 15:38:54.151504
3743	บริษัทนำเข้า 3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151507	2025-11-20 15:38:54.151506
3744	บริษัทนำเข้า 4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151509	2025-11-20 15:38:54.151508
3745	บริษัทนำเข้า 5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15151	2025-11-20 15:38:54.151509
3746	ธารทอง ขุมแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151512	2021-10-09 14:51:43
3747	อึ้งยู่เฮง2 ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151513	2025-09-03 12:50:13
3748	เยาวราชปางศิลาทอง กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151513	2021-03-25 17:12:32
3749	เยาวราชทอง นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151514	2025-10-21 18:55:11
3750	ศิริไทย เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151515	2021-03-27 17:44:46
3751	เพชรทองใบ เยาวราช (BENZ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151518	2021-06-30 14:56:15
3752	เยาวราชเพชรรัตน์ บึงกาฬ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15152	2024-07-20 15:01:13
3753	ศิริไพศาล กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151521	2025-05-15 15:36:37
3754	ศิริมงคล999 สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151522	2021-04-23 15:46:00
3755	พงษ์ทองดี11 สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151523	2021-04-04 16:06:01
3756	เกียวทอง ตราด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151524	2021-04-08 15:37:49
3757	เดอะเบสท์โกลด์แอนด์โกลด์ ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151524	2021-04-09 16:00:36
3758	ทองทิพย์แสงจันทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151525	2025-08-19 16:34:11
3759	เยาวราชมงคลเนรมิต แพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151526	2022-10-18 15:19:03
3760	เลี่ยวเซ็นหลี ชัยนาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151527	2021-04-20 16:19:09
3761	พีเอ็มทีโกลด์ หทัยราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151528	2021-05-12 15:56:58
3762	อู่ทองตาคลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151529	2021-04-22 14:44:18
3763	ห้างทองAA เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151532	2021-05-07 14:10:43
3764	ศรีเพชร (ฮกกี่)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151533	2023-04-06 16:37:36
3765	อมร พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151534	2025-10-22 12:17:00
3766	เกรียงชัยธนสมบูรณ์ ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151535	2022-09-03 15:28:51
3767	ซินหงีฟู 1 ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151536	2021-05-23 15:07:22
3768	เยาวราชหนองปรือ 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151537	2022-10-29 16:12:38
3769	พูนทรัพย์ สตูล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151538	2021-06-01 15:30:20
3770	ทองใบริช ฟิวเจอร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151539	2023-11-30 15:55:05
3771	ครูเพียร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15154	2025-09-12 14:36:06
3772	เยาวราชศรีนครินทร์ สาขา4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151542	2023-02-28 16:22:19
3773	พลอยจินดา นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151543	2025-01-22 11:27:46
3774	ใจดี พระอินทร์ราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151544	2024-03-16 10:44:27
3775	ยูพี ดอนตูม	0.00	32.700	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151545	2025-10-15 14:57:03
3776	กรรณิการ์ (ญาติ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151548	2022-08-02 10:04:43
3777	เจ๊จู3 เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151549	2023-09-30 15:55:48
3778	ทองช่วย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15155	2022-12-22 17:11:40
3779	เทพพิทักษ์ 7	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151551	2024-03-05 10:54:47
3780	เดอะริช มันนี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151552	2022-07-19 16:14:24
3781	ศรีธนา สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151553	2025-10-04 13:12:09
3782	ทินรัตน์ สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151554	2021-10-20 17:07:08
3783	เยาวราชบ้านเขว้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151556	2022-07-29 09:32:13
3784	SBK GOLD 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151558	2025-09-05 14:41:17
3785	ดาวศิลป์ กาญจนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151559	2025-05-06 15:33:06
3786	เฮงหลี โพธิ์สามต้น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15156	2021-12-14 00:00:00
3787	เยาวราช 2 โพทะเล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151561	2021-09-19 14:21:51
3788	เยาวราชตราด	7466.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151582	2022-07-29 16:14:54
3789	เยาวราช 9 มาร์เก็ตทูเดย์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151583	2024-05-31 12:48:00
3790	หมุยฮะ (เพื่อน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151584	2021-10-07 09:31:04
3791	เยาวราชนากลาง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151585	2021-10-30 17:23:12
3792	อัศวิน เยาวราช บางพลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151586	2022-11-24 15:43:20
3793	ช่างออย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151587	2021-11-21 09:25:55
3794	วรารัตน์ (ซ้อรัตน์)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151588	2021-10-16 09:20:57
3795	เทพพิทักษ์ 6	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151589	2022-12-09 10:18:06
3796	เล็กสมบูรณ์ บางบ่อ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151591	2025-04-18 11:07:32
3797	เยาวราชกรุงเทพ (ลูก)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151592	2022-04-16 16:05:31
3798	สมิทธิ์ ย ล	-16000000.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151593	2021-11-02 14:03:15
3799	JHL 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151596	2022-04-27 15:06:05
3800	ประสิทธิ์ทองคำ อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151599	2022-11-20 15:31:41
3801	ศรทอง1 อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1516	2023-03-05 09:31:50
3802	ไทยอุดม เยาวราช สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151601	2024-02-07 15:37:35
3803	เยาวราชเทิงนคร เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151602	2022-12-09 12:04:38
3804	โง้วซุนฮั้ว มังกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151604	2024-03-21 15:18:12
3805	เจมส์เนิร์ด 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151605	2021-11-17 14:00:44
3806	ช่างหนึ่ง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151606	2022-03-15 16:38:39
3807	คุณน้อย พี่ชายรัตน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151607	2024-07-03 13:45:16
3808	ทองดี เยาวราช ปทุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151608	2025-05-21 15:37:02
3809	ช่างอ๊อด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151608	2021-11-24 12:02:22
3810	ทองเเท้กรุงเทพ กาฬสินธุ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15161	2021-12-04 15:34:53
3811	อ.เยาวราช3 แหลมฉบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151611	2021-12-10 15:20:38
3812	ทองพันช่าง ลูกสาว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151614	2023-05-04 14:10:38
3813	ซังเต้ง ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151615	2025-09-19 15:19:48
3814	ซังเต้ง2 ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151616	2021-12-17 15:54:17
3815	เอกเซ่งฮวด 888	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151618	2021-12-17 16:02:01
3816	ทองใบ9 บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15162	2023-02-10 17:12:03
3817	แม่ยุพิน เซกา บึงกาฬ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151621	2021-12-19 15:29:02
3818	รุ่งโรจน์ เพชรบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151622	2021-12-21 16:50:04
3819	ทวีชัย ภูเขียว	0.00	0.000	0.000	152.450	0.000	0.000	0.000	2025-11-20 15:38:54.151623	2025-09-09 15:51:05
3820	เอกทองคำ พระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151624	2025-10-19 13:02:38
3821	เยาวราชมล ญาติ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151626	2023-05-14 13:12:32
3822	รติพรรณ พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151627	2023-02-11 11:35:36
3823	ช่างไพโรจน์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151628	2021-12-30 17:19:06
3824	ศรีธนา บ้านแพ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15163	2025-05-31 10:32:34
3825	สุขสมบูรณ์เยาวราช ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151631	2022-07-22 17:20:14
3826	ใจดี 304	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151632	2022-04-01 16:08:42
3827	ก๊วยเฮงเยาวราช ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151633	2025-10-11 09:54:09
3828	เทียนชัย พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151635	2022-01-09 10:31:55
3829	มีโชค บางลี่ 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151636	2022-08-05 12:31:23
3830	ปิ่นเพชร ลพบุรี	87.33	2.400	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151638	2024-06-25 14:23:12
3831	เก้าสุวรรณโกลด์ นนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151639	2022-04-30 15:31:54
3832	นำโชคเยาวราช อุดร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151639	2022-05-28 17:40:44
3833	*บุญอุดม (ฮกจ๋าย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15164	2022-08-11 00:00:00
3834	นับเงิน888	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151641	2025-10-16 18:14:16
3835	เยาวราชลานสัก อุทัยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151642	2022-01-23 17:03:28
3836	ถาวร สำโรง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151645	2022-02-09 18:52:17
3837	กุลศรีสุวรรณ หนองหอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151646	2025-02-01 16:02:53
3838	ทองศิริบุญชู เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151647	2025-09-05 15:32:00
3839	กรุงเทพ มังกรทอง ดอยสะเก็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151648	2025-10-25 15:24:34
3840	แม่ทองสวยเยาวราช หนองบัวลำภู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151649	2022-02-11 16:28:27
3841	เอ็งกิมเชียง ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15165	2022-02-12 15:17:28
3842	ไทยอุดม สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151651	2023-05-04 15:44:50
3843	พรีเมี่ยม โกลด์ เยาวราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151653	2022-09-15 15:19:55
3844	ศิริไพศาล ลำทับ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151654	2022-02-27 11:24:47
3845	แนน พนักงาน	6000.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151655	2025-08-31 10:25:06
3846	แสงทองเจริญ คลองสาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151657	2022-05-08 14:07:57
3847	พรสุวรรณ ท่ามะกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151659	2022-03-31 15:57:26
3848	ทองอัมรินทร์ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151662	2025-02-04 17:08:25
3849	ปลีก 11	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151663	2025-08-15 14:30:06
3850	ปลีก 12	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151664	2022-03-09 17:28:58
3851	ปลีก 14	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151665	2022-03-09 17:29:11
3852	อมรชัย (เจียระสุวรรณ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151666	2023-04-08 09:10:49
3853	ซือกิมเฮง ร้อยเอ็ด	0.00	0.000	0.000	533.550	0.000	0.000	0.000	2025-11-20 15:38:54.151667	2025-10-24 13:38:40
3854	คุณวรรณา แม่เพือนอุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151668	2022-03-16 09:35:01
3855	ช่างสนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15167	2025-05-03 11:50:35
3856	ไทยเอก ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151671	2024-02-16 16:00:14
3857	ทรัพย์ทวีวัฒนา สีคิ้ว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151672	2022-10-14 15:17:39
3858	100% สุพรรณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151673	2022-03-24 11:15:27
3859	ทองธรรมรัตน์168 อุทัยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151674	2025-10-25 15:40:29
3860	จินหยุน ชุมแสง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151677	2023-05-17 15:29:56
3861	วาสนา ทองสวย ปราณบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151678	2022-03-30 13:30:26
3862	เทพทองหนึ่ง ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151679	2022-04-16 13:32:54
3863	บัวชมพู กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15168	2022-04-28 12:44:47
3864	คุณ อร ดีดีรังสิต2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151681	2022-04-29 15:58:24
3865	มาทอง ขนอม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151682	2025-06-14 13:15:52
3866	ก้วงเหงียน อุตรดิตถ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151683	2025-07-11 14:42:02
3867	เยาวราชตั้งไทยฮะ บางกรวย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151685	2025-10-21 12:57:49
3868	เยาวราชเเม่เเจ่ม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151686	2022-05-13 12:59:52
3869	คุณบี้ ลิ้มจิงเฮียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151687	2025-07-30 14:55:50
3870	รัตนาเยาวราช นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151688	2025-09-20 15:18:15
3871	ทองศิริพร นครราชสีมา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151689	2025-05-09 15:21:40
3872	คุณกุ้ง หอแว่น	0.00	0.000	0.000	762.200	0.000	0.000	0.000	2025-11-20 15:38:54.151692	2025-10-22 17:52:14
3873	จักรพรรดิเยาวราช สงขลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151693	2025-10-07 11:41:56
3874	เยาวราชเจริญทรัพย์ 8 ปทุมธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151694	2022-05-19 16:05:44
3875	เยาวราชเจ๊มิ้งค์ ตากฟ้า	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151695	2023-08-22 16:40:06
3876	พนักงาน ตุ๊กกี้	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151696	2025-03-09 09:15:33
3877	คุณน้อย ตั๊กเซ่งเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151697	2022-05-22 14:19:29
3878	ทองเพิ่มพูน พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151698	2023-02-07 15:31:33
3879	คุณสวัสดิ์ชัย ( A )	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151701	2023-08-01 09:51:53
3880	เยาวราชสบบง พะเยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151702	2023-10-27 09:43:30
3881	ขวัญชัยบางน้ำเปรี้ยว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151703	2022-06-09 16:03:27
3882	สามสุวรรณ โกลด์ สมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151704	2023-12-16 16:07:51
3883	นพคุณพิพัฒน2 นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151707	2022-06-22 15:02:41
3884	คุณ ณัฎฐภาคย์ (น้องคุณแนต)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151709	2025-10-11 09:35:14
3885	ลายกนก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151711	2022-07-02 16:37:20
3886	อาญะเยาวราช ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151712	2025-01-26 12:03:19
3887	ทองเพิ่มพูน ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151713	2022-12-25 12:14:15
3888	คุณวรารัตน์ ญาติกนกพงศ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151714	2022-10-04 11:36:13
3889	ทองธรรมรงค์ ระยอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151715	2022-07-17 13:38:51
3890	วงศ์ทอง นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151716	2024-04-04 16:25:11
3891	ทองวาริน อุบล	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151717	2025-03-04 09:05:13
3892	จงรัก นครพนม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151718	2022-07-20 14:49:56
3893	ชิน3 ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151719	2022-08-25 15:40:41
3894	เจริญทรัพย์ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15172	2025-04-02 14:06:52
3895	วัฒนสิน เชียงใหม่	4386.14	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151721	2025-09-05 12:51:38
3896	ศิริเจริญ นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151723	2022-08-03 15:35:25
3897	ทรัพย์เจริญ ภูเก็ต	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151724	2022-11-05 15:56:01
3898	นานาเจริญ ปทุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151725	2025-03-27 15:42:36
3899	จิบเซ่งเฮง บางแค	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151726	2025-09-23 17:08:56
3900	ทองใบ พระประแดง ( นก )	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151727	2023-08-16 14:37:47
3901	เอพี โกลด์ มั่งคั่ง ร่ำรวย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151729	2022-10-05 08:53:50
3902	รุ่งทรัพยโกลด์  ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15173	2023-03-22 11:18:41
3903	เต็กส้วน กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151731	2022-08-30 17:11:55
3904	สินสมบูรณ์ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151732	2024-04-27 16:06:05
3905	ลิ่มบุญชัย 2 ยะลา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151733	2022-09-02 15:14:13
3906	เยาวราชตั้งเฮงเฮง ชุมพร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151734	2025-10-18 08:54:43
3907	ทองสุพรรณเยาวราช 3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151735	2022-09-23 15:35:08
3908	เยาวราชศรีปทุมทอง 	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151737	2024-04-27 15:59:39
3909	ตั๊กเซ่งเฮง Big C	0.00	0.000	0.000	-10213.350	0.000	-332.400	0.000	2025-11-20 15:38:54.151738	2025-10-26 09:22:44
3910	มั่งมีทรัพย์ พัทยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151739	2025-09-13 16:07:03
3911	เยาวราชเฮงหลี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151744	2023-12-24 15:25:32
3912	ทันยา บึงกาฬ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151745	2022-12-06 16:39:39
3913	นภาพัน ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151745	2022-12-24 15:24:46
3914	เยาวราชลำโพ บางบัวทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151747	2025-09-10 15:08:24
3915	ซื้อ หุ้น GT	-8250000.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151748	2022-10-28 09:12:27
3916	ใจดีมีน มาบตาพุด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151749	2022-11-01 15:32:52
3917	เพชรทองเฮง พิษณุโลก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15175	2022-11-08 15:58:12
3918	ออมทอง เยาวราช ลาดกระบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151751	2023-02-03 15:52:17
3919	ฉัตรทิพย์ สมุย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151752	2025-08-17 14:42:28
3920	Roger Kent	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151753	2023-12-13 13:46:50
3921	เยาวราชทองใบ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151755	2022-11-23 14:01:07
3922	พูลทรัพย์ กระบี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151756	2022-12-06 17:14:59
3923	เยาวราชฉลองกรุง ตลาดป้าไสว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151757	2025-10-24 14:04:23
3924	ทรัพย์รุ่งเรือง สมุทรปราการ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151758	2022-11-30 14:39:06
3925	เยาวราชฉลองกรุง บ่อวิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151759	2025-10-15 12:59:29
3926	ตั้งเซียมเฮง 4 พิจิตร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15176	2025-06-26 13:07:32
3927	รุ่งเรืองทรัพย์ บ้านหยิด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151761	2025-02-01 15:57:13
3929	เยาวราชพระนคร อยุธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151763	2022-12-06 14:38:23
3930	เฟื่องทอง 3 ปราจีนบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151764	2023-02-05 15:04:14
3931	แม่สุขใจ แก่งคอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151765	2022-12-17 16:59:06
3932	บุญสุวรรณ2 ฉะเชิงเทรา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151766	2023-01-05 14:21:16
3933	วังสิริ โพธาราม ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151769	2025-04-08 14:35:07
3934	เยาวราชแม่สะเรียง แม่ฮ่องสอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15177	2024-11-17 13:06:11
3935	ทองปิยะมาศ จอมทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151771	2023-02-03 12:51:13
3936	ไทยยนต์ ท่ามะกา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151772	2024-09-03 11:08:38
3937	รุ่งทวี เยาวราช คู้บอน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151773	2023-06-24 15:53:31
3938	บ้านทองแท้ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151773	2025-10-11 16:00:39
3939	พันช่าง บัวเชด สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151774	2023-02-04 14:07:38
3940	ปารีส ศรีราชา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151775	2023-08-02 16:14:39
3941	เรวดี นนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151776	2023-12-10 14:42:55
3942	วิสดอมลักชัวรี่ ราชเทวี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151777	2024-04-24 12:48:07
3943	ไทยมิตร พันท้าย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151779	2025-06-24 16:22:47
3944	ทองภัทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15178	2025-10-25 16:23:00
3945	เตียมุ่ยฮั้ว1 คลองขลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151783	2023-03-12 10:42:13
3946	ทองสวย เยาวราช พานทอง	0.00	0.000	0.000	76.200	0.000	0.000	0.000	2025-11-20 15:38:54.151783	2025-10-26 14:22:30
3947	รุ่งเรืองทรัพย์ โคกลอย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151784	2024-10-25 16:25:32
3948	รุ่งเรืองทรัพย์ สนามบิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151785	2025-04-05 16:08:52
3949	เยาวราชกรุงเทพ แม่สะเรียง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151786	2025-05-20 09:18:05
3950	น้องชายเจ๊ ชูอิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151787	2023-03-31 14:05:23
3951	ภูเก็ต โกรเชอรี่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151788	2025-08-22 14:18:04
3952	เยาวราช เจ้เหมียว	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151789	2025-05-28 16:26:04
3953	เยาวราชศรีนครินทร์ 5	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15179	2025-08-13 15:55:40
3954	ไทยรัก สังขะ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151791	2023-05-05 13:40:48
3955	ตั้งเฮงเฮง สาขาวงศกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151792	2023-06-22 12:25:00
3956	พัฒนาทองเจริญ ปทุม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151793	2025-06-25 13:01:33
3957	จิ้นเท้งเชียง พระราม2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151796	2025-10-24 17:06:06
3958	เฮงเจริญ เยาวราช คลอง4	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151797	2025-10-14 14:52:47
3959	เฮงรุ่งเรือง วัดดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151798	2025-10-11 11:18:56
3960	โกลด์เยาวราช ปลวกแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151799	2023-06-22 13:01:04
3961	สุขเกษม ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1518	2025-10-25 11:30:01
3962	เจริญรุ่งเรือง อ่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151801	2025-01-16 14:24:04
3963	ภัทรา999	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151816	2023-07-25 14:19:33
3964	แพรพันทอง ชลบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151817	2025-06-27 16:14:08
3965	ทองสุวรรณ สุโขทัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151818	2024-07-10 16:20:15
3966	เยาวราชศรีนครินทร์ 6	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151819	2023-08-09 15:34:56
3967	เยาวราชเฮงเฮง 9	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15182	2025-10-02 10:57:25
3968	พนักงาน นุ่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151822	2023-09-03 13:19:23
3969	แม่มนตรี 2 สุราษฎร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151825	2025-08-30 13:50:17
3970	กลมเกลียว ยานนาวา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151826	2023-09-13 15:16:46
3971	เทพพิทักษ์8	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151827	2023-10-03 10:07:23
3972	เยาวราช กรุงเทพ ตรามังกร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151829	2025-06-07 14:57:43
3973	น่ำเซ่งเฮง ราชเทวี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15183	2025-03-31 14:17:13
3974	ไทยเอก ละแม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151832	2025-06-01 13:43:38
3975	แต้จงเฮง ( มุก )	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151833	2025-09-25 13:42:51
3976	เยาวราชโพนทอง 3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151834	2024-07-02 15:24:45
3977	ทองเฮียกวง หนองคาย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151835	2023-12-16 17:12:10
3978	วิษณุ ( ปราณี )	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151836	2024-03-29 15:29:48
3979	ชนันท์ชัย สมุทรสาคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151837	2024-01-10 13:52:39
3980	ทวีทรัพย์ แพร่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151838	2024-07-05 11:26:11
3981	หวังทองดี นครสวรรค์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15184	2025-10-22 09:11:54
3982	แม่สมร เยาวราช ลำพูน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151841	2024-01-17 17:18:49
3983	สุขสมบูรณ์ ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151842	2025-06-22 13:13:40
3984	ลี้เม่งฮวด ชัยนาท	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151843	2024-02-13 16:50:46
3985	แม่เล็ก สิงห์บุรี	0.00	8.450	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151844	2025-10-09 09:58:06
3986	จิวเซ่งเฮง สกลนคร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151846	2024-02-22 10:59:49
3987	ลี้เม่งฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151847	2025-02-05 11:44:34
3988	ทองอารีย์ อ่างทอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151848	2025-10-25 10:15:13
3989	จงเจริญทอง2 นครศรีธรรมราช	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151849	2024-03-07 15:35:37
3990	ทองนับพรรณ ดินแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151851	2024-03-16 10:09:47
3991	ทองสดใส ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151852	2024-03-22 15:56:09
3992	แม่จำปี ร้อยเอ็ด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151853	2024-03-22 15:55:11
3993	อภิพัฒน์ กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151855	2024-03-28 15:09:21
3994	อภิชาติ กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151856	2024-03-28 15:09:52
3995	มานิดา กำแพงเพชร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151857	2024-03-28 15:10:24
3996	เยาวราชทองเอก ตรัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151858	2024-04-02 17:18:32
3997	สุภัสสร เยาวราช11 ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151859	2025-10-17 15:58:36
3998	โกยิ้ว ท่าม่วง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151861	2024-04-06 11:31:59
4000	โต๊ะกัง ดีดี อยูธยา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151863	2024-04-09 13:18:31
4001	โชคทรัพย์สิน เลย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151864	2024-05-26 13:21:38
4002	คุณหญิง 204	0.00	0.000	0.000	45.700	0.000	0.000	0.000	2025-11-20 15:38:54.151865	2025-04-02 16:40:50
4003	พรศิริรุ่งเรือง เชียงคาน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151866	2025-07-26 14:58:41
4004	คุณ เปรม เพืีอน น้องอุ้ย	300.00	0.000	0.000	914.700	0.000	0.000	0.000	2025-11-20 15:38:54.151867	2025-10-21 16:16:43
4005	ครูนนท์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15187	2025-05-21 12:34:32
4006	แม่ซิ้วเตียน 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151873	2024-06-01 09:53:13
4007	เหรียญทองโกลด์ เพชรบูรณ์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151874	2025-09-23 11:21:58
4008	หลีสิ่นฮิ้น 2 ราชบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151875	2024-06-06 15:10:20
4009	คุณญาณี (จิตสุดา)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151876	2024-10-16 15:53:35
4010	ชาญ ค้าทองแท่ง แม่สาย	251741.00	0.000	0.000	0.000	0.000	-23500.000	0.000	2025-11-20 15:38:54.151877	2025-10-26 14:46:37
4011	คุณ ธนากร (ใจดีมีน)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151878	2024-10-03 09:49:39
4012	คุณ ED 825	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151879	2024-07-04 15:41:26
4013	พรเจริญ บางโพ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15188	2024-06-23 10:30:59
4014	คุณทศพล (อุ่ยอุทัยเทิง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151881	2024-09-25 13:27:37
4015	คุณหทัยชนก (ครูจีน อุ้ย)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151883	2024-11-27 12:52:07
4016	เยาวราชทุ่งคอก สองพี่น้อง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151884	2024-08-15 15:31:09
4017	คุณรุ่งทิพย์ (ช่างแหม่ม)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151887	2025-10-22 12:50:59
4018	คุณสาธิต (มังกรฟ้า)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151888	2024-08-24 15:46:03
4019	จักรพรรดิ์ บางปู	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151888	2024-12-07 16:05:59
4020	สินสุวรรณ 5 สระบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151889	2024-09-13 14:29:54
4021	แสงทองใบ เยาวราช เรวดี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15189	2025-02-01 13:33:27
4022	บุญมณี แพรกษา	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151892	2024-10-16 13:38:37
4023	ยูบิลลี่ เอ็นเตอร์ไพรส์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151893	2024-10-24 13:44:01
4024	ลานสักวิทยุ อุทัยธานี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151894	2024-10-31 13:50:24
4025	ทองสยาม ปลวกแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151895	2025-05-31 15:12:58
4026	พนักงาน กัน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151896	2024-11-13 16:39:08
4027	คุณกิตติพงษ์ 204	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151897	2024-12-07 15:33:00
4028	นำทอง เยาวราช บางใหญ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151898	2025-10-08 16:19:56
4029	กันเอง 1 ปราจีน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.1519	2025-06-21 12:55:35
4030	คุณ อาย เพื่อยอุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151902	2024-12-24 17:13:31
4031	เอ็งฮงฮวด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151903	2024-12-21 17:00:57
4032	สหพัฒน์ ศรีราชา 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151904	2025-10-11 12:44:15
4033	เยาวราชละอุ่น ระนอง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151905	2025-02-02 09:29:49
4034	เจษสุวรรณ ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151906	2025-09-30 16:39:22
4035	รุ่งทรัพย์ตลาดหัวรอ อยุธยา 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151907	2025-02-15 14:15:08
4036	พนักงาน แบม	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151908	2025-08-07 14:49:35
4037	คิมเฮง เยาวราช ปลวกแดง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151909	2025-10-08 08:44:04
4038	ทองแท้เยาวราข ลาดบัวหลวง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151911	2025-02-27 12:09:05
4039	โชคชัย เยาวราช บ้านไผ่	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151913	2025-09-13 15:19:46
4040	รภัสโกลด์ ขอนแก่น	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151914	2025-08-01 16:24:14
4041	คุณเหมี่ยว ( เฮียน้อย )	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151916	2025-03-07 13:27:03
4042	สามดาว2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151918	2025-10-22 11:59:52
4043	รัชดา เยาวราช สุรินทร์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151919	2025-03-09 14:19:23
4044	คุณลัคนา (ตั้งคุงฮะ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15192	2025-09-30 15:58:06
4045	วีไอพี(วีไอพี ซาฟารี)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151921	2025-03-18 15:44:49
4046	MAGIC GEMSTONE	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151922	2025-03-18 15:55:36
4047	พนักงาน มิ้น	24177.00	0.000	0.000	1.000	0.000	0.000	0.000	2025-11-20 15:38:54.151923	2025-10-07 16:53:16
4048	สายอุทัย 3	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151924	2025-09-10 13:35:03
4049	ห้างทองสมศักดิ์ทำทอง(ตลาดสำเภาทอง)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151925	2025-04-19 13:12:14
4050	เพชรทองคำ เยาวราช1982	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151926	2025-10-04 16:52:48
4051	เยาวราชกรุงเทพเส็ง บางปะอิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151927	2025-08-19 13:40:18
4052	นงนุช สมุย 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151928	2025-04-26 10:13:08
4053	ทองสมิธ เยาวราช เชียงราย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151932	2025-05-02 15:48:44
4054	แม่เง็ก  แหลมฉบัง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151933	2025-05-06 16:56:55
4055	ทับเที่ยงโกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151934	2025-07-16 14:03:03
4056	คุณ แหวว ญาติสุรชัย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151935	2025-07-23 10:58:07
4057	แม่บุญเรือง เชียงใหม่ โกลด์ บูลเลี่ยน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151937	2025-06-09 11:14:14
4058	อุดมพรรณ สนามหลวง 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151938	2025-10-15 15:25:01
4059	มหาสวัสดิ์ (ฐิติพรรณ)	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151939	2025-06-18 14:45:51
4060	คุณแจงMC ( บริษัท เอ็น เอส ที เวนเจอร์ส จำกัด )	0.00	0.000	0.000	609.750	0.000	0.000	0.000	2025-11-20 15:38:54.15194	2025-10-15 08:58:19
4061	คุณแดงน้อย ( เฮียหยุด )	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151941	2025-08-15 13:51:53
4062	โอีตทองคำ	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151942	2025-09-17 15:31:32
4063	พรหมประทานธนภัทร	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151943	2025-09-03 15:37:25
4064	ไฟน์โกลด์	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151944	2025-10-26 14:07:08
4065	คุณหลา รัดสาด	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151945	2025-10-21 14:46:48
4066	แม่ทองใบ อมตะ นนทบุรี	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151947	2025-09-23 14:42:49
4067	จิวบ่วงเฮง นนท์	0.00	4.350	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151948	2025-10-15 14:24:38
4068	ซือกิมเฮง เชียงใหม่	-220.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151949	2025-10-24 15:33:41
4069	เยาวราชนิคม สมุทรปราการ 2	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.15195	2025-10-08 15:34:28
4070	คุณพอช เพื่อนน้องอุ้ย	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151952	2025-10-09 13:02:26
4071	ทองใบเยาวราช สี่เเยกวัดตึก	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151953	2025-10-21 17:19:22
4072	คุณจิตติ จิ้นฮั้วเฮง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151954	2025-10-21 11:42:56
4073	ภครัช เยาวราช พัทลุง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151955	2025-10-18 17:21:20
4	ไพลิน	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145271	2025-11-20 15:41:55.157554
3547	9 มงคล ภูเก็ต	0.00	76.250	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.151258	2025-11-20 15:44:30.413118
344	ยู่หลงกิมกี่	-44055791.00	0.000	0.000	-20525.000	0.000	-8000.000	0.000	2025-11-20 15:38:54.145783	2025-11-20 16:47:54.863951
413	ศรีทองพระโขนง	0.00	0.000	0.000	0.000	0.000	0.000	0.000	2025-11-20 15:38:54.145899	2025-11-21 17:11:15.747997
\.


--
-- Data for Name: jewelry_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jewelry_types (id, name, created_at) FROM stdin;
0	ค่าแรง	2025-11-25 13:14:21.443074
1	คอ	2025-11-25 13:14:21.443074
2	มือ	2025-11-25 13:14:21.443074
3	แหวน	2025-11-25 13:14:21.443074
4	กำไล	2025-11-25 13:14:21.443074
5	จี้	2025-11-25 13:14:21.443074
6	พวงกุญแจ	2025-11-25 13:14:21.443074
7	ต่างหู	2025-11-25 13:14:21.443074
8	สร้อยข้อเท้า	2025-11-25 13:14:21.443074
9	เข็มขัด	2025-11-25 13:14:21.443074
10	กิ๊บ	2025-11-25 13:14:21.443074
11	ตะขอ	2025-11-25 13:14:21.443074
12	อะไหล่	2025-11-25 13:14:21.443074
99	อื่นๆ	2025-11-25 13:14:21.443074
\.


--
-- Data for Name: nominal_weights; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nominal_weights (id, label, weight_grams, created_at) FROM stdin;
1	½ส	1.900	2025-11-25 13:18:39.599477
2	1ส	3.800	2025-11-25 13:18:39.599477
3	2ส	7.600	2025-11-25 13:18:39.599477
4	3ส	11.400	2025-11-25 13:18:39.599477
5	1บ	15.200	2025-11-25 13:18:39.599477
6	6ส	22.800	2025-11-25 13:18:39.599477
7	2บ	30.400	2025-11-25 13:18:39.599477
8	3บ	45.600	2025-11-25 13:18:39.599477
9	4บ	60.800	2025-11-25 13:18:39.599477
10	5บ	76.000	2025-11-25 13:18:39.599477
\.


--
-- Data for Name: pack_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pack_items (id, pack_id, display_order, deduction_rate, shape, purity, description, weight_grams, weight_baht, calculation_amount) FROM stdin;
3	2	1	0	bar	96.500	\N	15.244	\N	30500.00
4	2	2	0	bar	96.500	\N	15.244	\N	30500.00
\.


--
-- Data for Name: packs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.packs (id, group_id, internal_id, user_number) FROM stdin;
1	11	1	PACK-001
2	15	1	PACK-001
\.


--
-- Data for Name: transaction_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaction_items (id, transaction_id, display_order, transaction_type, amount_money, amount_grams, amount_baht, balance_type, price_rate, conversion_charge_rate, split_charge_rate, block_making_charge_rate, source_amount_grams, source_amount_baht, dest_amount_grams, dest_amount_baht) FROM stdin;
3	3	1	money_out	100000.00	\N	\N	jewel	\N	\N	\N	\N	\N	\N	\N	\N
4	4	1	money_in	62000.00	\N	\N	bar96	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transactions (id, group_id) FROM stdin;
1	10
2	12
3	14
4	16
\.


--
-- Data for Name: tray_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tray_items (id, tray_id, display_order, making_charge, jewelry_type_id, design_name, nominal_weight, quantity, amount, nominal_weight_id) FROM stdin;
4	2	1	500	\N	\N	1.000	1	30500	\N
5	2	2	800	\N	\N	2.000	1	60800	\N
6	2	3	300	\N	\N	0.500	1	15300	\N
53	3	1	300	2	เกลียวคลื่น	1.000	2	600	\N
58	4	2	250	1	คตกิตพิกุล	30.400	4	1000	7
57	4	1	400	1	ระย้าสี่เสาลงยา	45.600	5	2000	8
\.


--
-- Data for Name: trays; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trays (id, group_id, internal_num, is_return, purity, shape, discount, actual_weight_grams, price_rate, additional_charge_rate) FROM stdin;
2	5	1	f	96.500	jewelry	5	53.354	30000.00	\N
3	9	1	f	96.500	jewelry	5	53.354	30000.00	\N
4	13	1	f	100.000	jewelry	10	53.354	63000.00	\N
\.


--
-- Name: bill_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bill_groups_id_seq', 16, true);


--
-- Name: bills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bills_id_seq', 6, true);


--
-- Name: customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_id_seq', 4073, true);


--
-- Name: jewelry_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jewelry_types_id_seq', 18, true);


--
-- Name: pack_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pack_items_id_seq', 4, true);


--
-- Name: packs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.packs_id_seq', 2, true);


--
-- Name: transaction_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transaction_items_id_seq', 4, true);


--
-- Name: transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_id_seq', 4, true);


--
-- Name: tray_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tray_items_id_seq', 58, true);


--
-- Name: trays_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trays_id_seq', 4, true);


--
-- Name: bill_groups bill_groups_bill_id_display_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill_groups
    ADD CONSTRAINT bill_groups_bill_id_display_order_key UNIQUE (bill_id, display_order);


--
-- Name: bill_groups bill_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill_groups
    ADD CONSTRAINT bill_groups_pkey PRIMARY KEY (id);


--
-- Name: bills bills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: jewelry_types jewelry_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jewelry_types
    ADD CONSTRAINT jewelry_types_name_key UNIQUE (name);


--
-- Name: jewelry_types jewelry_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jewelry_types
    ADD CONSTRAINT jewelry_types_pkey PRIMARY KEY (id);


--
-- Name: nominal_weights nominal_weights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nominal_weights
    ADD CONSTRAINT nominal_weights_pkey PRIMARY KEY (id);


--
-- Name: pack_items pack_items_pack_id_display_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_items
    ADD CONSTRAINT pack_items_pack_id_display_order_key UNIQUE (pack_id, display_order);


--
-- Name: pack_items pack_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_items
    ADD CONSTRAINT pack_items_pkey PRIMARY KEY (id);


--
-- Name: packs packs_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_group_id_key UNIQUE (group_id);


--
-- Name: packs packs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_pkey PRIMARY KEY (id);


--
-- Name: transaction_items transaction_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_pkey PRIMARY KEY (id);


--
-- Name: transaction_items transaction_items_transaction_id_display_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_transaction_id_display_order_key UNIQUE (transaction_id, display_order);


--
-- Name: transactions transactions_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_group_id_key UNIQUE (group_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: tray_items tray_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tray_items
    ADD CONSTRAINT tray_items_pkey PRIMARY KEY (id);


--
-- Name: tray_items tray_items_tray_id_display_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tray_items
    ADD CONSTRAINT tray_items_tray_id_display_order_key UNIQUE (tray_id, display_order);


--
-- Name: trays trays_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trays
    ADD CONSTRAINT trays_group_id_key UNIQUE (group_id);


--
-- Name: trays trays_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trays
    ADD CONSTRAINT trays_pkey PRIMARY KEY (id);


--
-- Name: idx_bill_groups_bill_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bill_groups_bill_id ON public.bill_groups USING btree (bill_id);


--
-- Name: idx_bills_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_customer_id ON public.bills USING btree (customer_id);


--
-- Name: idx_bills_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_date ON public.bills USING btree (date);


--
-- Name: idx_bills_is_finalized; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bills_is_finalized ON public.bills USING btree (is_finalized);


--
-- Name: idx_customer_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customer_updated_at ON public.customer USING btree (updated_at);


--
-- Name: idx_pack_items_pack_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pack_items_pack_id ON public.pack_items USING btree (pack_id);


--
-- Name: idx_packs_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_packs_group_id ON public.packs USING btree (group_id);


--
-- Name: idx_transaction_items_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaction_items_transaction_id ON public.transaction_items USING btree (transaction_id);


--
-- Name: idx_transactions_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_group_id ON public.transactions USING btree (group_id);


--
-- Name: idx_tray_items_tray_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tray_items_tray_id ON public.tray_items USING btree (tray_id);


--
-- Name: idx_trays_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_trays_group_id ON public.trays USING btree (group_id);


--
-- Name: customer update_customer_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_customer_updated_at BEFORE UPDATE ON public.customer FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bill_groups bill_groups_bill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bill_groups
    ADD CONSTRAINT bill_groups_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES public.bills(id) ON DELETE CASCADE;


--
-- Name: bills bills_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(id);


--
-- Name: pack_items pack_items_pack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pack_items
    ADD CONSTRAINT pack_items_pack_id_fkey FOREIGN KEY (pack_id) REFERENCES public.packs(id) ON DELETE CASCADE;


--
-- Name: packs packs_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packs
    ADD CONSTRAINT packs_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.bill_groups(id) ON DELETE CASCADE;


--
-- Name: transaction_items transaction_items_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.bill_groups(id) ON DELETE CASCADE;


--
-- Name: tray_items tray_items_nominal_weight_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tray_items
    ADD CONSTRAINT tray_items_nominal_weight_id_fkey FOREIGN KEY (nominal_weight_id) REFERENCES public.nominal_weights(id);


--
-- Name: tray_items tray_items_tray_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tray_items
    ADD CONSTRAINT tray_items_tray_id_fkey FOREIGN KEY (tray_id) REFERENCES public.trays(id) ON DELETE CASCADE;


--
-- Name: trays trays_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trays
    ADD CONSTRAINT trays_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.bill_groups(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict am1URVFHfiFxXCEJ4I1gxP2mFRbYjyJyvYO2VR01VisfbPOkuaCdCQF6fXGlgVs

