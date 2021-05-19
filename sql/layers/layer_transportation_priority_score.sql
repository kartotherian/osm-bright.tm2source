/*
  layer_transportation_priority_score computes the order priority for the feature based on its
  class: grouped transportation feature type
  is: can be 'tunnel', 'road' or 'bridge'
  z_order: the z-order of the feature as defined by the dataset
*/
CREATE OR REPLACE FUNCTION public.layer_transportation_priority_score(class text, is text, z_order integer)
  RETURNS integer
AS
  $$
    declare
      feature_priority integer;
      feature_boost integer;
      final_score integer;

    BEGIN
      -- setup CTE for order boosting
      WITH ordertable_cte(feature_class, priority) AS (
          VALUES
            ('motorway', 1000),
            ('main', 900),
            ('street', 800),
            ('motorway_link', 700),
            ('street_limited', 600),
            ('driveway', 500),
            ('major_rail', 400),
            ('service', 300),
            ('minor_rail', 200),
            ('path', 100)
      )

      -- feature_priority
      SELECT
        priority
      FROM
        ordertable_cte
      WHERE
        feature_class = class
      INTO
        feature_priority
      ;

      -- feature_boost
      SELECT
        CASE "is"
          WHEN 'tunnel' THEN -100000
          WHEN 'road' THEN 0
          WHEN 'bridge' THEN 100000
          ELSE bail_out('Unexpected layer_transportation_priority_score value for is=%s', "is")::INT
        END INTO feature_boost
      ;

      -- compute final_score
      SELECT
        z_order + feature_priority + feature_boost
      INTO final_score;

      RETURN final_score;
    END;
  $$ language 'plpgsql';
