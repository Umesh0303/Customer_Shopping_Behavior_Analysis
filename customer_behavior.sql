
--Q1. Compare total revenue by gender.
SELECT gender,
       SUM(purchase_amount) AS revenue_total
FROM customer
GROUP BY gender;

--Q2. Find customers who used a discount and still spent above the overall average.
SELECT customer_id,
       purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer);

--Q3. List the top 5 items ranked by average review score.
SELECT item_purchased,
       ROUND(AVG(CAST(review_rating AS NUMERIC)), 2) AS avg_review_score
FROM customer
GROUP BY item_purchased
ORDER BY avg_review_score DESC
LIMIT 5;

--Q4. Compare average purchase amounts for Standard versus Express shipping.
SELECT shipping_type,
       ROUND(AVG(purchase_amount), 2) AS average_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

--Q5. Compare subscriber and non-subscriber performance.
SELECT subscription_status,
       COUNT(*) AS customer_count,
       ROUND(AVG(purchase_amount), 2) AS average_spend,
       ROUND(SUM(purchase_amount), 2) AS revenue_sum
FROM customer
GROUP BY subscription_status
ORDER BY revenue_sum DESC, average_spend DESC;

--Q6. Identify the 5 items with the highest percent of discounted sales.
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS discount_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

--Q7. Classify customers as New, Returning, or Loyal and count each segment.
WITH customer_segments AS (
    SELECT customer_id,
           previous_purchases,
           CASE
               WHEN previous_purchases = 1 THEN 'New'
               WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
               ELSE 'Loyal'
           END AS loyalty_segment
    FROM customer
)
SELECT loyalty_segment,
       COUNT(*) AS segment_size
FROM customer_segments
GROUP BY loyalty_segment;

--Q8. Show the top 3 products by purchase count for each category.
WITH ranked_items AS (
    SELECT category,
           item_purchased,
           COUNT(*) AS purchase_count,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rank_in_category
    FROM customer
    GROUP BY category, item_purchased
)
SELECT rank_in_category,
       category,
       item_purchased,
       purchase_count
FROM ranked_items
WHERE rank_in_category <= 3;

--Q9. Count repeat buyers (more than 5 previous purchases) by subscription status.
SELECT subscription_status,
       COUNT(*) AS repeat_buyer_count
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--Q10. Compute revenue contribution per age group.
SELECT age_group,
       SUM(purchase_amount) AS revenue_by_age_group
FROM customer
GROUP BY age_group
ORDER BY revenue_by_age_group DESC;

