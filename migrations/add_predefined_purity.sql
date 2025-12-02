-- Create predefined_purity table
CREATE TABLE IF NOT EXISTS predefined_purity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    display VARCHAR(20) NOT NULL,
    purity NUMERIC(6,3)
);

-- Insert predefined purity values
INSERT INTO predefined_purity (name, display, purity) VALUES
('ทอง', '96.5%', NULL),
('นาก', '42.5%', 42.5),
('นาก', '53.125%', 53.125),
('ทอง', '90%', 90),
('ทอง', '99.99%', 100);
