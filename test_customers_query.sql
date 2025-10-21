SELECT 
  customers.id, 
  customers.name, 
  cast(count(invoices.id) as int) as invoice_count,
  cast(count(tracker_projects.id) as int) as project_count,
  coalesce(
    json_agg(
      distinct jsonb_build_object(
        'id', tags.id,
        'name', tags.name
      )
    ) filter (where tags.id is not null),
    '[]'
  ) as tags
FROM customers 
LEFT JOIN invoices ON invoices.customer_id = customers.id 
LEFT JOIN tracker_projects ON tracker_projects.customer_id = customers.id 
LEFT JOIN customer_tags ON customer_tags.customer_id = customers.id 
LEFT JOIN tags ON tags.id = customer_tags.tag_id 
WHERE customers.team_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb' 
GROUP BY customers.id 
LIMIT 5;
