CREATE DATABASE estoque
	CHARACTER SET utf8mb4 
	COLLATE utf8mb4_general_ci;

USE estoque;

CREATE TABLE `produto` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
    `status` CHAR (1) NOT NULL DEFAULT 'A',
    `descricao` VARCHAR (50) NULL DEFAULT NULL,
    `estoque_minimo` INT (11) NULL DEFAULT NULL,
    `estoque_maximo` INT (11) NULL DEFAULT NULL, 
	PRIMARY KEY (`id`)
);

INSERT INTO `produto` (`status`, `descricao`, `estoque_minimo`, `estoque_maximo`)  VALUES 
('A', 'CANETA', 10, 100),
('A', 'LAPIS', 10, 100),
('A', 'BORRACHA', 5, 50),
('A', 'LAPISEIRA', 5, 40),
('A', 'CORRETIVO', 5, 20);

CREATE TABLE `entrada_produto` (
	`id` INT (11) NOT NULL AUTO_INCREMENT,
    `id_produto` INT (11) NULL DEFAULT NULL,
    `qtde` INT (11) NULL DEFAULT NULL,
    `valor_unitario` DECIMAL (9, 2) NULL DEFAULT '0.00',
    `data_entrada` DATE NULL DEFAULT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE `estoque` (
	`id` INT (11) NOT NULL AUTO_INCREMENT,
    `id_produto` INT (11) NULL DEFAULT NULL,
	`qtde` INT (11) NULL DEFAULT NULL,
    `valor_unitario` DECIMAL (9, 2) NULL DEFAULT '0.00',
    PRIMARY KEY (`id`)
);

CREATE TABLE `saida_produto` (
	`id` INT (11) NOT NULL AUTO_INCREMENT,
    `id_produto` INT (11) NULL DEFAULT NULL,
    `qtde` INT (11) NULL DEFAULT NULL,
    `data_saida` DATE NULL DEFAULT NULL,
    `valor_unitario` DECIMAL (9, 2) NULL DEFAULT '0.00',
    PRIMARY KEY (`id`)
);

DELIMITER //
CREATE PROCEDURE `SP_AtualizaEstoque` 
(`id_prod` INT, 
`qtde_comprada` INT, 
valor_unit DECIMAL (9, 2))
BEGIN 
DECLARE `contador` INT (11);
SELECT COUNT(*) INTO  CONTADOR FROM `estoque` WHERE `id_produto` = `id_prod`;
IF CONTADOR > 0 THEN
	UPDATE `estoque` SET `qtde`=`qtde` + `qtde_comprada`, `valor_unitario` = `valor_unit`
	WHERE `id_produto` = `id_prod`;
ELSE
	INSERT INTO `estoque` (`id_produto`, `qtde`, `valor_unitario`)
    VALUES (`id_prod`, `qtde_comprada`, `valor_unit`);
END IF;
END //
DELIMITER ;

-- ENTRADA INSERIR PRODUTO
DELIMITER //
CREATE TRIGGER `TRG_EntradaProduto_AI` AFTER INSERT ON `entrada_produto`
FOR EACH ROW
BEGIN
	CALL SP_AtualizaEstoque (NEW.`id_produto`, NEW.`qtde`, NEW.`valor_unitario`);
END //
DELIMITER ;

-- ENTRADA ATUALIZAR PRODUTO
DELIMITER //
CREATE TRIGGER `TRG_EntradaProduto_AU` AFTER UPDATE ON `entrada_produto`
FOR EACH ROW
BEGIN
	CALL SP_AtualizaEstoque (NEW.`id_produto`, NEW.`qtde` - OLD.`qtde`, NEW.`valor_unitario`);
END //
DELIMITER ;

-- ENTRADA DELETE PRODUTO
DELIMITER //
CREATE TRIGGER `TRG_EntradaProduto_AD` AFTER DELETE ON `entrada_produto`
FOR EACH ROW
BEGIN
	CALL SP_AtualizaEstoque (OLD.`id_produto`, OLD.`qtde` * -1, OLD.`valor_unitario`);
END //
DELIMITER ;

-- SAIDA INSERIR PRODUTO
DELIMITER //
CREATE TRIGGER `TRG_SaidaProduto_AI` AFTER INSERT ON `saida_produto`
FOR EACH ROW
BEGIN
	CALL SP_AtualizaEstoque (NEW.`id_produto`, NEW.`qtde` * -1, NEW.`valor_unitario`);
END //
DELIMITER ;

-- SAIDA UPDATE PRODUTO
DELIMITER //
CREATE TRIGGER `TRG_SaidaProduto_AU` AFTER UPDATE ON `saida_produto`
FOR EACH ROW
BEGIN
	CALL SP_AtualizaEstoque (NEW.`id_produto`, OLD.`qtde` - NEW.`qtde`, NEW.`valor_unitario`);
END //
DELIMITER ;

-- SAIDA DELETE PRODUTO
DELIMITER //
CREATE TRIGGER `TRG_SaidaProduto_AD` AFTER DELETE ON `saida_produto`
FOR EACH ROW
BEGIN
	CALL SP_AtualizaEstoque (OLD.`id_produto`, OLD.`qtde`, OLD.`valor_unitario`);
END //
DELIMITER ;

INSERT INTO `entrada_produto` (`id_produto`, `qtde`, `valor_unitario`, `data_entrada`) VALUES
(1, 10, 2.00, '2012-11-08'),
(1, 15, 2.50, '2012-11-10'),
(2, 5, 1.00, '2012-11-10'),
(4, 10, 3.00, '2012-11-10');

INSERT INTO `saida_produto` (`id_produto`, `qtde`, `data_saida`, `valor_unitario`) VALUES
(1, 3, '2012-11-13', 2.5),
(4, 2, '2012-11-13', 3.0),
(2, 5, '2012-11-11', 1.0);

SELECT * FROM `entrada_produto`;
SELECT * FROM `saida_produto`;

SELECT `estoque`.`id` AS `ID` ,`estoque`.`id_produto` AS `Produto`, `produto`.`descricao` AS `Descrição`, `estoque`.`qtde` AS `Quantidade`, `estoque`.`valor_unitario` AS `Preço Unitário`
FROM `estoque`
INNER JOIN `produto` ON `estoque`.`id_produto` = `produto`.`id`;
