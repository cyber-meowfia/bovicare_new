-- ==============================================================================
-- BoviCare Migration: Auto-Confirm Users & Disable Email Verification Requirement
-- ==============================================================================
-- 1. Marks all existing users in auth.users as email-confirmed.
-- 2. Automatically confirms any new signups on insert.
-- 3. Eliminates email verification requirements and email rate-limit bottlenecks.
-- ==============================================================================

-- 1. Auto-confirm existing unconfirmed users
UPDATE auth.users
SET email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
    confirmed_at = COALESCE(confirmed_at, NOW())
WHERE email_confirmed_at IS NULL;

-- 2. Trigger function to auto-confirm every new user upon creation
CREATE OR REPLACE FUNCTION public.handle_new_user_auto_confirm()
RETURNS trigger AS $$
BEGIN
  NEW.email_confirmed_at = COALESCE(NEW.email_confirmed_at, NOW());
  BEGIN
    NEW.confirmed_at = COALESCE(NEW.confirmed_at, NOW());
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Bind trigger to auth.users table
DROP TRIGGER IF EXISTS trg_auto_confirm_users ON auth.users;
CREATE TRIGGER trg_auto_confirm_users
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user_auto_confirm();
