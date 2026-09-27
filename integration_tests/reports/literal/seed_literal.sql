create temp table places as
select * from (values
  ('o' || chr(39) || 'hare', 1),
  ('back' || chr(92) || 'slash', 2),
  (chr(39) || chr(92) || chr(39), 4),
  ('plain', 8)
) t(name, n);
