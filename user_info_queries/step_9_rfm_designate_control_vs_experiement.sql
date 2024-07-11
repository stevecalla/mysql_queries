-- GENERATE CONTROL VS EXPERIMENT GROUPS

-- ASSIGN CONTROL OR EXPERIMENT BY USER ID
SELECT 
	user_ptr_id,
    score_three_parts,
    CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
FROM rfm_score_summary_history_data_backup
ORDER BY user_ptr_id;

-- DISPLAY THE TOTAL COUNT AND % OF TOTAL BY CONTROL / EXPERIMENT
SELECT 
    test_group,
    COUNT(*) AS group_count,
    CONCAT(FORMAT(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2), '%') AS percentage_of_total
FROM (
    SELECT 
		CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group
    FROM rfm_score_summary_history_data_backup
) AS a
GROUP BY test_group
ORDER BY test_group;

-- DISPLAY THE COUNT & % TOTAL BY SCORE THREE PARTS
SELECT 
    test_group,
    score_three_parts,
    COUNT(*) AS group_count,
    CONCAT(FORMAT(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY score_three_parts) * 100, 2), '%') AS percentage_of_group
FROM (
    SELECT 
        CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group,
        score_three_parts
    FROM rfm_score_summary_history_data_backup
) AS a
GROUP BY test_group, score_three_parts
ORDER BY score_three_parts, test_group;

-- DISPLAY THE COUNT & % TOTAL BY SCORE THREE PARTS
SELECT 
    test_group,
    score_five_parts,
    COUNT(*) AS group_count,
    CONCAT(FORMAT(COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY score_five_parts) * 100, 2), '%') AS percentage_of_group
FROM (
    SELECT 
        CASE WHEN RAND() < 0.2 THEN 'Control' ELSE 'Experiment' END AS test_group,
        score_five_parts
    FROM rfm_score_summary_history_data_backup
) AS a
GROUP BY test_group, score_five_parts
ORDER BY score_five_parts, test_group;





