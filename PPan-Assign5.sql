-- 1. How many containers of antibiotics are currently available?
SELECT SUM(quantityOnHand) AS antibioticContainersAvailable
FROM item
WHERE itemDescription LIKE '%antibiotics%';

-- 2. Volunteers whose phone number does not start with 2 and whose last name is not Jones
SELECT volunteerName
FROM volunteer
WHERE volunteerTelephone NOT LIKE '2%'
  AND volunteerName NOT LIKE '% Jones';

-- 3. Volunteers working on transporting tasks
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId = assignment.volunteerId
JOIN task ON assignment.taskCode = task.taskCode
JOIN task_type ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName = 'transporting';

-- 4. Tasks not yet assigned to any volunteer
SELECT task.taskDescription
FROM task
LEFT JOIN assignment ON task.taskCode = assignment.taskCode
WHERE assignment.taskCode IS NULL;

-- 5. Package types that contain some kind of bottle
SELECT DISTINCT package_type.packageTypeName
FROM package_type
JOIN package ON package_type.packageTypeId = package.packageTypeId
JOIN package_contents ON package.packageId = package_contents.packageId
JOIN item ON package_contents.itemId = item.itemId
WHERE item.itemDescription LIKE '%bottle%';

-- 6. Items that are not in any package
SELECT item.itemDescription
FROM item
LEFT JOIN package_contents ON item.itemId = package_contents.itemId
WHERE package_contents.itemId IS NULL;

-- 7. Tasks assigned to volunteers who live in New Jersey
SELECT task.taskDescription
FROM task
JOIN assignment ON task.taskCode = assignment.taskCode
JOIN volunteer ON assignment.volunteerId = volunteer.volunteerId
WHERE volunteer.volunteerAddress LIKE '%NJ'
GROUP BY task.taskCode, task.taskDescription;

-- 8. Volunteers who began their assignments in the first half of 2021
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId = assignment.volunteerId
WHERE assignment.startDateTime >= '2021-01-01'
  AND assignment.startDateTime < '2021-07-01';

-- 9. Volunteers assigned to tasks that include packing spam
SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId = assignment.volunteerId
JOIN package ON assignment.taskCode = package.taskCode
JOIN package_contents ON package.packageId = package_contents.packageId
JOIN item ON package_contents.itemId = item.itemId
WHERE item.itemDescription LIKE '%spam%';

-- 10. Items with a total value of exactly $100 in one package
SELECT DISTINCT item.itemDescription
FROM item
JOIN package_contents ON item.itemId = package_contents.itemId
WHERE item.itemValue * package_contents.itemQuantity = 100;

-- 11. Number of volunteers assigned to tasks with each status, highest to lowest
SELECT task_status.taskStatusName AS taskStatus,
       COUNT(DISTINCT assignment.volunteerId) AS numVolunteers
FROM task_status
JOIN task ON task_status.taskStatusId = task.taskStatusId
JOIN assignment ON task.taskCode = assignment.taskCode
GROUP BY task_status.taskStatusId, task_status.taskStatusName
ORDER BY numVolunteers DESC;

-- 12. Task that creates the heaviest set of packages, and the weight (no sub-queries)
SELECT taskCode, SUM(packageWeight) AS totalWeight
FROM package
GROUP BY taskCode
ORDER BY totalWeight DESC
LIMIT 1;

-- 13. Number of tasks that do not have the type "packing"
SELECT COUNT(*) AS nonPackingTasks
FROM task
JOIN task_type ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName <> 'packing';

-- 14. Packed items that were touched by fewer than 3 volunteers
SELECT item.itemDescription
FROM item
JOIN package_contents ON item.itemId = package_contents.itemId
JOIN package ON package_contents.packageId = package.packageId
LEFT JOIN assignment ON package.taskCode = assignment.taskCode
GROUP BY item.itemId, item.itemDescription
HAVING COUNT(DISTINCT assignment.volunteerId) < 3;

-- 15. Packages with a total value over 100, lowest to highest
SELECT package_contents.packageId,
       SUM(item.itemValue * package_contents.itemQuantity) AS totalValue
FROM package_contents
JOIN item ON package_contents.itemId = item.itemId
GROUP BY package_contents.packageId
HAVING SUM(item.itemValue * package_contents.itemQuantity) > 100
ORDER BY totalValue ASC;
