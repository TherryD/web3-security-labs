# 🛡️ Web3 Smart Contract Security Labs

Repositório dedicado aos meus estudos práticos de auditoria de contratos inteligentes, análise estática e desenvolvimento de Provas de Conceito (PoCs) utilizando **Foundry** e **Slither**.

## 📂 Laboratórios Implementados

### 1. Reentrancy Attack & CEI Mitigation
* **Contrato:** `src/Counter.sol`
* **Prova de Conceito (PoC):** `test/Counter.t.sol`
* **Vulnerabilidade:** Violação do padrão *Checks-Effects-Interactions* (CEI), permitindo chamadas recursivas na função `sacar()` via `receive()` antes da atualização do saldo do usuário.
* **Mitigação:** Atualização de estado (`saldos[msg.sender] = 0`) antes da chamada externa `.call` ou aplicação de `ReentrancyGuard`.

### 2. Ethernaut Level 01 — Fallback
* **Contrato:** `src/Fallback.sol`
* **Prova de Conceito (PoC):** `test/Fallback.t.sol`
* **Vulnerabilidade:** Escalação de privilégios (*Privilege Escalation*) através da função `receive()`, permitindo assumir a variável administrativa `owner` e drenar o saldo do contrato sem cumprir a regra principal de contribuições.

---

## 🛠️ Ferramentas Utilizadas
* **Foundry (`forge`):** Compilação, simulação de EVM local e escrita de testes de exploração.
* **Slither (`slither-analyzer`):** Análise estática automatizada para triagem de vulnerabilidades.
* **Solidity (`^0.8.20`):** Desenvolvimento e revisão de contratos inteligentes.

---

## 🚀 Como Executar Localmente

1. Clone o repositorio:
    git clone https://github.com/therryd/web3-security-labs.git
    cd web3-security-labs

2. Execute as Provas de Conceito com logs detalhados:
    forge test -vv

3. Execute a analise estatica com o Slither:
    slither .
