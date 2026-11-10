-- Faturamento por id_pedido com desconto 
SELECT id_pedido, 
 ROUND(
        SUM(
            CASE
                WHEN desconto IS NOT NULL AND desconto > 0
                    THEN quantidade * preco_unitario * (1 - desconto)
                ELSE quantidade * preco_unitario
            END
        ), 2
    ) AS Total_Pedido
FROM itens_pedido
GROUP by id_pedido;

-- Clientes com Mais de 5 pedidos
SELECT
    c.id_cliente,
    c.nome_cliente,
    COUNT(p.id_pedido) AS Quantidade_Pedidos
FROM clientes c
INNER JOIN pedidos p
    ON c.id_cliente = p.id_cliente
GROUP BY
    c.id_cliente,
    c.nome_cliente
HAVING COUNT(p.id_pedido) > 5
ORDER BY Quantidade_Pedidos DESC;

-- Os 5 produtos mais vendidos por quantidade
SELECT p.nome_produto, ip.id_produto,sum(quantidade) as Quantidade_de_Produtos 
from itens_pedido ip
JOIN produtos p on p.id_produto = ip.id_produto
WHERE ip.id_pedido IN (
    SELECT id_pedido
    FROM pedidos
    WHERE status_pedido = 'Concluído')
GROUP by ip.id_produto
ORDER By Quantidade_de_Produtos DESC
LIMIT 5;

-- Faturamento mensal de pedidos concluídos
SELECT strftime('%m', data_pedido) as Meses, 
 ROUND(
        SUM(
            CASE
                WHEN desconto IS NOT NULL AND desconto > 0
                    THEN quantidade * preco_unitario * (1 - desconto)
                ELSE quantidade * preco_unitario
            END
        ), 2
    ) AS Total_Pedido
FROM itens_pedido ip
JOIN pedidos p on p.id_pedido = ip.id_pedido
WHERE p.status_pedido = 'Concluído'
GROUP by Meses;

