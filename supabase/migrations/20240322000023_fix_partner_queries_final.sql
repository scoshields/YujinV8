-- Drop existing foreign key constraints
ALTER TABLE workout_partners 
DROP CONSTRAINT IF EXISTS workout_partners_user_id_fkey,
DROP CONSTRAINT IF EXISTS workout_partners_partner_id_fkey;

-- Recreate foreign key constraints with explicit names
ALTER TABLE workout_partners
ADD CONSTRAINT workout_partners_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
ADD CONSTRAINT workout_partners_partner_id_fkey 
  FOREIGN KEY (partner_id) REFERENCES users(id) ON DELETE CASCADE;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for involved users" ON workout_partners;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON workout_partners;
DROP POLICY IF EXISTS "Enable update for involved users" ON workout_partners;
DROP POLICY IF EXISTS "Enable delete for owners" ON workout_partners;

-- Create new policies with proper checks
CREATE POLICY "Enable read access for involved users" ON workout_partners
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM users WHERE id IN (user_id, partner_id)
    )
  );

CREATE POLICY "Enable insert for authenticated users" ON workout_partners
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM users WHERE id = user_id)
  );

CREATE POLICY "Enable update for involved users" ON workout_partners
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT id FROM users WHERE id IN (user_id, partner_id)
    )
  );

CREATE POLICY "Enable delete for owners" ON workout_partners
  FOR DELETE USING (
    auth.uid() IN (SELECT id FROM users WHERE id = user_id)
  );

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_workout_partners_user_id ON workout_partners(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_partners_partner_id ON workout_partners(partner_id);
CREATE INDEX IF NOT EXISTS idx_workout_partners_status ON workout_partners(status);
CREATE INDEX IF NOT EXISTS idx_workout_partners_is_favorite ON workout_partners(is_favorite);