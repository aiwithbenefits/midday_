-- Drop and create tracker helper functions

DROP FUNCTION IF EXISTS total_duration(tracker_projects);
DROP FUNCTION IF EXISTS get_project_total_amount(tracker_projects);

-- Function to calculate total duration for a project
CREATE OR REPLACE FUNCTION total_duration(project_row tracker_projects)
RETURNS bigint
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(SUM(te.duration), 0)::bigint
  FROM tracker_entries te
  WHERE te.project_id = project_row.id;
$$;

-- Function to calculate total amount for a project
CREATE OR REPLACE FUNCTION get_project_total_amount(project_row tracker_projects)
RETURNS numeric
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    SUM(
      CASE 
        WHEN te.rate IS NOT NULL THEN (te.duration / 3600.0) * te.rate
        WHEN project_row.rate IS NOT NULL THEN (te.duration / 3600.0) * project_row.rate
        ELSE 0
      END
    ), 
    0
  )
  FROM tracker_entries te
  WHERE te.project_id = project_row.id;
$$;

COMMENT ON FUNCTION total_duration IS 'Calculates total duration (in seconds) for a tracker project';
COMMENT ON FUNCTION get_project_total_amount IS 'Calculates total billable amount for a tracker project based on duration and rate';
