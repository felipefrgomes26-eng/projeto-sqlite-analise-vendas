-- Top 10 mais caros
SELECT * FROM produtos
ORDER by preco_atual DESC
LIMIT 10;

-- Ordenando clientes por estado
SELECT estado, COUNT(*) as Clientes_estado from clientes
GROUP by estado;

-- Pedidos realizados em 2025
SELECT * FROM pedidos
WHERE strftime ('%Y' , data_pedido) = '2025';

-- Pedidos por status
SELECT status_pedido, COUNT(*) as Quantidade_de_Pedidos from pedidos
GROUP by status_pedido
ORDER BY Quantidade_de_Pedidos DESC;
