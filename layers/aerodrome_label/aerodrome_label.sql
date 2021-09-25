
-- etldoc: layer_aerodrome_label[shape=record fillcolor=lightpink, style="rounded,filled", label="layer_aerodrome_label | <z8> z8 | <z9> z9 | <z10_> z10+" ] ;

CREATE OR REPLACE FUNCTION layer_aerodrome_label(bbox geometry,
                                                 zoom_level integer)
    RETURNS TABLE
            (
                id       bigint,
                geometry geometry,
                name     text,
                name_en  text,
                tags     hstore,
                class    text,
                ele      int
            )
AS
$$
SELECT
    -- etldoc: osm_aerodrome_label_point -> layer_aerodrome_label:z8
    -- etldoc: osm_aerodrome_label_point -> layer_aerodrome_label:z9
    ABS(osm_id) AS id, -- mvt feature IDs can't be negative
    geometry,
    name,
    COALESCE(NULLIF(name_en, ''), name) AS name_en,
    tags,
    CASE
        %%FIELD_MAPPING: class %%
        ELSE 'other'
        END AS class,
    substring(ele FROM E'^(-?\\d+)(\\D|$)')::int AS ele
FROM osm_aerodrome_label_point
WHERE geometry && bbox
  AND zoom_level >= 10;
$$ LANGUAGE SQL STABLE
                -- STRICT
                PARALLEL SAFE;
