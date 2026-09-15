---
_label: "Non-Blocking Distributed MPSC Queues"
description: "Wait-free distributed MPSC queues using MPI-3 RMA"
---

[Full thesis (PDF)](report/main.pdf)

Distributed applications such as the actor model and fan-out/fan-in pattern require MPSC queues that are both performant and fault-tolerant. We address the absence of non-blocking distributed MPSC queues by adapting LTQueue, a wait-free shared-memory MPSC queue, to distributed environments using MPI-3 RMA. We introduce three novel **wait-free** distributed MPSC queues: **dLTQueue**, **Slotqueue**, and **dLTQueueV2**.

Evaluation on SuperMUC-NG and CoolMUC-4 shows ~2x better enqueue throughput than the existing AMQueue while providing stronger fault tolerance.

## Publications

1. **dLTQueue** - FDSE 2025 ([ResearchGate](https://www.researchgate.net/publication/395381301_dLTQueue_A_Non-Blocking_Distributed-Memory_Multi-Producer_Single-Consumer_Queue))
2. **Slotqueue** - NPC 2025 ([ResearchGate](https://www.researchgate.net/publication/395448251_Slotqueue_A_Wait-Free_Distributed_Multi-Producer_Single-Consumer_Queue_with_Constant_Remote_Operations))

## Motivation

The demand for computation power has been increasing relentlessly. To harness the power of distributed systems, specialized algorithms and data structures need to be devised. Two especially important properties are performance and fault tolerance. MPSC queues are essential for **irregular applications** - programs with unpredictable, data-dependent memory access patterns:

- **Actor model**: Each actor maintains a mailbox (MPSC queue) receiving messages from other actors
- **Fan-out/fan-in**: Worker nodes enqueue results to an aggregation node for processing

These patterns demand queues that are both performant and fault-tolerant. A slow or crashed producer should not block the entire system.

## Gap in the Literature

We survey existing non-blocking MPSC queues in both the shared-memory and distributed domains. The **shared-memory** domain has several non-blocking MPSC queues: LTQueue, DQueue, WRLQueue, and Jiffy. However, our analysis reveals critical flaws in most:

| Queue | Issue |
| --- | --- |
| DQueue | Incorrect ABA solution and unsafe memory reclamation |
| WRLQueue | Actually **blocking** - dequeuer waits for all enqueuers |
| Jiffy | Insufficient memory reclamation, not truly wait-free |
| **LTQueue** | **Correct** - uses LL/SC for ABA, proper memory reclamation |

The **distributed** domain has only one MPSC queue: **AMQueue**. Despite claiming lock-freedom, it is actually **blocking** - the dequeuer must wait for all enqueuers to finish.

## Our Approach

Based on the survey, we adapt **LTQueue**, the only correct shared-memory MPSC queue, to distributed environments using MPI-3 RMA one-sided communication.

**Key challenge**: LTQueue relies on LL/SC (Load-Link/Store-Conditional) to solve the ABA problem, but LL/SC is unavailable in MPI.

**Our solution**: Replace LL/SC with CAS + unique timestamps. Each value is tagged with a monotonically increasing version number, preventing ABA without LL/SC.

**Key techniques**:

- **SPSC-per-enqueuer**: Each producer maintains a local queue, eliminating producer contention
- **Unique timestamps**: Solves ABA via monotonic version numbers
- **Double-refresh**: Bounds retries to two per node, ensuring wait-freedom

## Novel Algorithms

This research makes two primary contributions: an application of a novel design technique for non-blocking distributed data structures via adaptation of non-blocking shared-memory data structures, and three novel wait-free distributed MPSC queues:

| Algorithm | Progress | Enqueue | Dequeue |
| --- | --- | --- | --- |
| **dLTQueue** | Wait-free | $O(\log n)$ remote | $O(\log n)$ remote |
| **Slotqueue** | Wait-free | $O(1)$ remote | $O(1)$ remote, $O(n)$ local |
| **dLTQueueV2** | Wait-free | $O(1)$ remote | $O(1)$ remote, $O(\log n)$ local |

All algorithms are **linearizable** with no dynamic memory allocation.

## Results

We benchmark our algorithms on [SuperMUC-NG](https://doku.lrz.de/supermuc-ng-10745965.html) (6000+ nodes) and [CoolMUC-4](https://doku.lrz.de/coolmuc-4-10746415.html) (100+ nodes), compared against the existing AMQueue:

| Metric | Our Queues vs AMQueue |
| --- | --- |
| Enqueue throughput | **~2x better** |
| Dequeue throughput | 3-10x worse |
| Fault tolerance | **Wait-free** (vs blocking) |

**Trade-off**: Stronger fault tolerance at the cost of dequeue performance.
