-- Create extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create farms table
CREATE TABLE IF NOT EXISTS farms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  location TEXT,
  user_id TEXT NOT NULL,
  description TEXT,
  total_area REAL,
  main_crop TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create lots table
CREATE TABLE IF NOT EXISTS lots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  area REAL NOT NULL,
  current_harvest TEXT NOT NULL,
  coordinates JSONB,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  expiration_date TEXT,
  quantity INTEGER NOT NULL,
  status TEXT NOT NULL,
  photo_url TEXT,
  barcode TEXT,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  cost REAL NOT NULL,
  photo_url TEXT,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  description TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  type TEXT NOT NULL,
  daily_rate REAL NOT NULL,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  assigned_employees JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create harvests table
CREATE TABLE IF NOT EXISTS harvests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  coffee_type TEXT NOT NULL,
  total_quantity INTEGER NOT NULL,
  quality INTEGER NOT NULL,
  weather TEXT,
  lot_id UUID NOT NULL REFERENCES lots(id) ON DELETE CASCADE,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  used_products JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create product_uses table
CREATE TABLE IF NOT EXISTS product_uses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  use_date TIMESTAMP WITH TIME ZONE NOT NULL,
  description TEXT NOT NULL,
  used_quantity INTEGER NOT NULL,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  harvest_id UUID REFERENCES harvests(id) ON DELETE SET NULL,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create employee_productions table
CREATE TABLE IF NOT EXISTS employee_productions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  measure_quantity INTEGER NOT NULL,
  value_per_measure REAL NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  total_received REAL NOT NULL,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  harvest_id UUID NOT NULL REFERENCES harvests(id) ON DELETE CASCADE,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create daily_receipts table
CREATE TABLE IF NOT EXISTS daily_receipts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  type TEXT NOT NULL,
  description TEXT NOT NULL,
  amount_paid REAL NOT NULL,
  measure INTEGER,
  print_status TEXT NOT NULL,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  harvest_id UUID REFERENCES harvests(id) ON DELETE SET NULL,
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  farm_id UUID NOT NULL REFERENCES farms(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create RLS policies for each table
-- Enable Row Level Security
ALTER TABLE lots ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE harvests ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_uses ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_productions ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_receipts ENABLE ROW LEVEL SECURITY;

-- Create policies for each table to restrict access to authenticated users with matching farm_id
CREATE POLICY "Users can CRUD their own lots" ON lots
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own products" ON products
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own employees" ON employees
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own tasks" ON tasks
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own harvests" ON harvests
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own product_uses" ON product_uses
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own employee_productions" ON employee_productions
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can CRUD their own daily_receipts" ON daily_receipts
  FOR ALL USING (
    farm_id IN (
      SELECT id FROM farms WHERE user_id = auth.uid()
    )
  );

-- Create functions and triggers for updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers for each table
CREATE TRIGGER update_lots_updated_at
BEFORE UPDATE ON lots
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_employees_updated_at
BEFORE UPDATE ON employees
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_harvests_updated_at
BEFORE UPDATE ON harvests
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_product_uses_updated_at
BEFORE UPDATE ON product_uses
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_employee_productions_updated_at
BEFORE UPDATE ON employee_productions
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

CREATE TRIGGER update_daily_receipts_updated_at
BEFORE UPDATE ON daily_receipts
FOR EACH ROW EXECUTE PROCEDURE update_modified_column(); 