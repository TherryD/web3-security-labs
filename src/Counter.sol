// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CofreVulneravel
 * @notice Contrato educacional demonstrando uma vulnerabilidade clássica de Reentrância (Reentrancy).
 * @dev A falha ocorre por violar o padrão Checks-Effects-Interactions (CEI), enviando ETH antes de zerar o saldo.
 */
contract CofreVulneravel {
    // Mapeia o endereço de cada usuário para o seu saldo depositado em Wei
    mapping(address => uint256) public saldos;

    /// @notice Permite que qualquer usuário deposite ETH no cofre
    function depositar() external payable {
        saldos[msg.sender] += msg.value;
    }

    /// @notice Permite que o usuário saque seu saldo total
    function sacar() external {
        // 1. CHECK: Verifica se o usuário possui saldo disponível
        uint256 valor = saldos[msg.sender];
        require(valor > 0, "Sem saldo para sacar");

        // 2. INTERACTION (Vulnerável): Envia o ETH para o chamador ANTES de atualizar o estado.
        // Se msg.sender for um contrato, a função receive() dele será disparada aqui,
        // permitindo chamar sacar() novamente em loop antes que o saldo seja zerado.
        (bool sucesso, ) = msg.sender.call{value: valor}("");
        require(sucesso, "Falha ao enviar ETH");

        // 3. EFFECT (Tardio): Zera o saldo apenas após o término das chamadas externas.
        // MITIGAÇÃO: Mover esta linha para antes do `msg.sender.call` (padrão CEI) ou usar `ReentrancyGuard`.
        saldos[msg.sender] = 0;
    }
}