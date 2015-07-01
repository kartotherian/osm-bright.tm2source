-- Safe string to int conversion, on invalid input retrns 0 instead of raising an error
CREATE OR REPLACE FUNCTION to_int(s TEXT) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE WHEN s~E'^\\d+$' THEN s::INTEGER ELSE 0 END;
END;
$$ LANGUAGE plpgsql;
