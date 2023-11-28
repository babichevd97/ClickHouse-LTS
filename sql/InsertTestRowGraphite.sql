INSERT INTO distributed_graphite
SELECT 'aa', toFloat64(number), 1111111 * number, toDate('2016-06-15'), 1111111 + number FROM system.numbers LIMIT 10000;