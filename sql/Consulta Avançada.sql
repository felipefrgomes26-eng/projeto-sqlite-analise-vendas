-- Clientes cujo total supera a média
WITH Media_Cliente AS (
    SELECT
        c.id_cliente,
        c.nome_cliente,
        AVG(Total_Pedido) AS Media_Consumo
    FROM clientes c
    JOIN pedidos p
        ON c.id_cliente = p.id_cliente
    JOIN (
        SELECT
            id_pedido,
            SUM(quantidade * preco_unitario * (1 - desconto)) AS Total_Pedido
        FROM itens_pedido
        GROUP BY id_pedido
    ) ip
        ON p.id_pedido = ip.id_pedido
    WHERE p.status_pedido = 'Concluído'
    GROUP BY c.id_cliente, c.nome_cliente
)

SELECT
    id_cliente,
    nome_cliente,
    ROUND(Media_Consumo, 2) AS Media_Consumo
FROM Media_Cliente
WHERE Media_Consumo > (
    SELECT AVG(Media_Consumo)
    FROM Media_Cliente
)
ORDER BY Media_Consumo DESC;

-- Produtos que nunca foram vendidos
SELECT
    pr.id_produto,
    pr.nome_produto
FROM produtos pr
LEFT JOIN itens_pedido ip
    ON pr.id_produto = ip.id_produto
LEFT JOIN pedidos p
    ON ip.id_pedido = p.id_pedido
GROUP BY pr.id_produto, pr.nome_produto
HAVING SUM(
    CASE
        WHEN p.status_pedido <> 'Cancelado' THEN 1
        ELSE 0
    END
) = 0;

-- Produtos empatados em Maior quantidade vendida
WITH Total_Produtos AS (
    SELECT
        pr.id_produto,
        pr.nome_produto,
        SUM(ip.quantidade) AS Total_Vendido
    FROM produtos pr
    JOIN itens_pedido ip
        ON pr.id_produto = ip.id_produto
    JOIN pedidos p
        ON ip.id_pedido = p.id_pedido
    WHERE p.status_pedido <> 'Cancelado'
    GROUP BY pr.id_produto, pr.nome_produto
)

SELECT
    id_produto,
    nome_produto,
    Total_Vendido
FROM Total_Produtos
WHERE Total_Vendido = (
    SELECT MAX(Total_Vendido)
    FROM Total_Produtos
)
ORDER BY id_produto;

-- Faturamento mensal usando LAG
WITH Faturamento_Mensal AS (
    SELECT
        strftime('%m', p.data_pedido) AS Mes,
        ROUND(
            SUM(
                ip.quantidade * ip.preco_unitario * (1 - ip.desconto)
            ), 2
        ) AS Faturamento
    FROM itens_pedido ip
    JOIN pedidos p
        ON ip.id_pedido = p.id_pedido
    WHERE p.status_pedido = 'Concluído'
    GROUP BY Mes
)

SELECT
    Mes,
    Faturamento,
    LAG(Faturamento) OVER (ORDER BY Mes) AS Faturamento_Anterior,
    ROUND(
        Faturamento - LAG(Faturamento) OVER (ORDER BY Mes),
        2
    ) AS Diferenca
FROM Faturamento_Mensal
ORDER BY Mes;
