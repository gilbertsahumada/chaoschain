# ChaosSettler — Hackathon Planning

Iteraciones del diseño de ChaosSettler para Chainlink Convergence Hackathon (Feb 6 - Mar 1, 2026).

## Documentos

| Doc | Contenido | Estado |
|-----|-----------|--------|
| `v1_feasibility.md` | Análisis de viabilidad técnica. Inventario del codebase, qué existe vs qué es aspiracional, viability matrix de 8 puntos de integración CRE ↔ ChaosChain | Base |
| `v2_plan_and_privacy.md` | Primer plan de hackathon. Flujo propuesto, privacy como commit-reveal + private transactions, plan de 3 semanas, riesgos | Superado por v4 |
| `v3_agents_flow.md` | Modelo de agentes (push/pull híbrido), qué transacciones necesitan privacidad, pseudocódigo de agentes | Vigente, complementa v4 |
| `v4_cre_deep_integration.md` | CRE como agregador privado de scores (no solo trigger). Scores nunca on-chain, solo consenso. Modificaciones a Gateway, SDK, contratos. Timeline revisado | Vigente, complementa v5 |
| `v5_game_theory.md` | Análisis de game theory: por qué no coludir, incentivos para resolver correctamente, modelo de rewards (fijo vs % de volumen), matriz de vulnerabilidades | Vigente |
| `v6_flow_and_resolution.md` | Flujo completo market→resolución. 3 modelos de resolución (evidence, challenge-response A2A, híbrido). Proof of Knowledge via CRE | Vigente |
| `v7_cre_resolution_flow.md` | CRE como motor de resolución. El CRE Resolution Workflow ES el producto. Setup flow, challenge generation, scope mínimo vs ideal | Superado por v8 |
| `v8_plan_final.md` | Plan final v1. Sin verifiers (CRE+LLM es el evaluador). Worker agent con A2A. Validaciones técnicas, timeline 3 semanas | Superado por v9 |
| `v9_evidence_privacy_and_cre_facts.md` | Evidence privada hasta resolución. CRE facts con fuentes reales. Non-determinism constraint | Vigente |
| `v10_rewards_and_final_design.md` | **Diseño final.** Reward model (quality × correctness × reputation). Max 10 workers. Flujo completo simplificado. Lista de qué construir | Vigente |
| `v11_sdk_integration.md` | **Integración SDK.** Qué partes de ChaosChain usamos vs no. ChaosSettlerResolver.sol nuevo (~80 líneas). Flujo SDK↔CRE↔contratos. Seguridad | Superado por v12 |
| `v12_viability_analysis.md` | **Análisis de viabilidad.** 4 caminos mapeados, 6 problemas del Camino A (incluye SDK=Gateway), comparación honesta A vs B | Vigente |
| `v13_standalone_baseline.md` | **Baseline sin ChaosChain.** ChaosSettlerMarket.sol standalone (~200 líneas) + ERC-8004 independiente. Workers como oráculos de IA. Flujo completo, demo 3 mercados, timeline 3 semanas, ~700 líneas total | Activo (fallback) |
| `v14_chaoschain_integration.md` | **Integración genuina con ChaosChain.** +65 líneas en RewardsDistributor (StudioProxy sin cambios). Workers como oráculos descentralizados de IA. Cross-domain reputation, agent NFT identity, atomic rewards+rep. Demo música→resolución. +1 día vs v13 | Activo (recomendado) |

## Decisiones Tomadas

- **Workers son oráculos descentralizados de IA** — no predicen, investigan y determinan el resultado real
- Terminología: determination (no prediction), /a2a/resolve (no /a2a/predict), RESOLUTION_QUALITY, ACCURATE/INACCURATE
- ChaosChain se usa (justificado por infraestructura existente)
- No claims de "trustless" — el framing es "accountable with verifiable reputation"
- CRE es el privacy + aggregation layer, no solo trigger
- Scores individuales nunca on-chain (solo consenso agregado via CRE)
- Agentes son autónomos (push), sistema orquesta timing (pull)
- Privacy es la defensa primaria contra colusión (voto secreto = imposible coordinar)
- Staking, privacy y reputación son complementarios (los 3 juntos > cualquiera solo)
- ChaosChain es solo resolutor (resolution-as-a-service), no la plataforma de prediction markets
- Challenge-response via A2A es lo principal — Proof of Knowledge
- CRE cierra el market: en ese workflow ocurre toda la magia (challenges + scores + consensus + write)
- No hay verifiers separados — CRE + LLM ES el evaluador imparcial
- Challenge Q&A no se persiste (CRE stateless = la privacidad es que se pierde)
- Arweave fetch no necesita Confidential HTTP (los datos ya son públicos)
- Evidence NO es pública antes de resolución (commit hash on-chain, evidence en worker server)
- CRE fetch evidence privadamente via Confidential HTTP → worker A2A
- Gateway y Arweave NO están en el critical path de resolución
- SDK de ChaosChain SÍ se usa: registro de workers + staking (identidad + skin in the game)
- Gateway workflow engine NO se usa para resolución (CRE lo reemplaza)
- RewardsDistributor.closeEpoch() NO se usa (modelo incompatible, espera validadores + MAD)
- RewardsDistributor se EXTIENDE con resolveAndDistribute() (~65 líneas) — no se reemplaza
- StudioProxy SIN CAMBIOS — escrow, registerAgent, withdraw funcionan tal cual
- A2A endpoints viven en metadata URI del agent NFT (ERC-8004 Identity Registry), no en contratos

## Pendiente

- Asistir workshop de private transactions (puede complementar o reemplazar Confidential HTTP approach)
- Validar que Confidential HTTP permita fetch de payload grande (todos los scores de un epoch)
- Decidir: ¿stake mínimo = f(rewardPool) en contrato? (fortalece narrativa anti-colusión)
- Decidir: ¿reputation gating básico al registro de agentes?
- Definir timeout/grace period: si CRE no resuelve, fondos retornan al creador
- Crear repo `chaossettler/` con estructura: contracts/, cre-workflow/, agent/, scripts/
- Implementar Worker Agent (FastAPI A2A: /a2a/resolve, /a2a/challenge)
- Implementar resolveAndDistribute() en RewardsDistributor
- Implementar CRE Resolution Workflow (TypeScript → WASM)
