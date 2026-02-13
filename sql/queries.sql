-- Demonstração das análises exploratórias do projeto usando SQL
-- SQL dialect: MySQL
-- Dataset: Olist (Brazilian E-commerce Public Dataset)

-- TOP 15 ESTADOS COM MAIOR VOLUME DE PEDIDOS
SELECT 
    c.customer_state AS estado,
    COUNT(o.order_id) AS total_pedidos,
    ROUND(COUNT(o.order_id) * 100.0 / 
          (SELECT COUNT(*) FROM olist_orders_dataset WHERE order_status = 'delivered'), 2) AS percentual
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_pedidos DESC
LIMIT 15;


-- EVOLUÇÃO DO VOLUME DE PEDIDOS
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS mes,
    COUNT(order_id) AS total_pedidos
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY mes;


-- DISTRIBUIÇÃO DOS MÉTODOS DE PAGAMENTO
SELECT 
    payment_type AS metodo_pagamento,
    COUNT(*) AS total_transacoes,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_order_payments_dataset), 2) AS percentual
FROM olist_order_payments_dataset
WHERE payment_type != 'not_defined'
GROUP BY payment_type
ORDER BY total_transacoes DESC;


-- TEMPO MÉDIO DAS ETAPAS DO PEDIDO
SELECT 
    'Compra -> Aprovação' AS etapa,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_approved_at)), 2) AS media_horas
FROM olist_orders_dataset
WHERE order_approved_at IS NOT NULL

UNION ALL

SELECT 
    'Aprovação -> Envio' AS etapa,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_approved_at, order_delivered_carrier_date)), 2) AS media_horas
FROM olist_orders_dataset
WHERE order_delivered_carrier_date IS NOT NULL

UNION ALL

SELECT 
    'Envio -> Entrega' AS etapa,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_delivered_carrier_date, order_delivered_customer_date)), 2) AS media_horas
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;


-- CUMPRIMENTO DE PRAZO DE ENTREGA
SELECT 
    CASE 
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'No prazo'
        ELSE 'Atrasado'
    END AS status_entrega,
    COUNT(*) AS total_pedidos,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_orders_dataset WHERE order_status = 'delivered'), 2) AS percentual
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY status_entrega;


-- DISTRIBUIÇÃO DAS AVALIAÇÕES
SELECT 
    r.review_score,
    COUNT(r.order_id) AS total_avaliacoes,
    ROUND(COUNT(r.order_id) * 100.0 / (SELECT COUNT(*) FROM olist_order_reviews_dataset), 2) AS percentual
FROM olist_order_reviews_dataset r
JOIN olist_orders_dataset o ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY r.review_score
ORDER BY r.review_score DESC;
