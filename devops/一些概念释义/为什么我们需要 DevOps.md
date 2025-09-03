
转发：知乎专栏：https://zhuanlan.zhihu.com/coding-net

## **企业在成长过程中碰到的实际问题**

很快，随着 CODING 业务的发展，CODING 的产品线越来越多，团队也越来越大，当团队到达 100 人的时候（其中 60% 都是研发），我们发现团队开始"管不动"了，最终的上线质量非常依赖部门 Leader 的管理能力和开发者的自我修养。为了保证产品达到预期，我们制定了大量流程和规范，但这让我们的进度越变越慢了。我们一度非常苦恼，创业公司的优势在于极高的效率与极快的产品迭代，但如果我们在发展的过程中丢失了这样的优势，将会很轻易的被别人超过。

所幸我们并不是第一个碰到这个问题的人。《[人月神话](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E4%BA%BA%E6%9C%88%E7%A5%9E%E8%AF%9D&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLkurrmnIjnpZ7or50iLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.YwiXFGMOBXme4kOx-GeWG94XotcqwmX1ejB4cfsvviU&zhida_source=entity)》中有个很著名的观点：

> _Adding manpower to a late software project makes it later._  
> _-- Fred Brooks, (1975)_

“**如果希望用增加人力的方式解决软件的进度问题，只会让进度变得更慢。**”因为：

> _沟通成本= n(n-1)/2 n=团队人数_

举例而言 10 个人的团队将有 45 个沟通管道，当人数到达 50 人时，这个数字将上升为 1225 个。随着人数的增多，团队内的沟通成本将指数级上升。了解到问题出现的原因，也就知道了解决方案：“我们需要更多更小的团队”——**通过将团队分成若干个内部闭环的小团队来降低沟通成本**。于是我们有了一个稍微敏捷一点的[组织架构](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E7%BB%84%E7%BB%87%E6%9E%B6%E6%9E%84&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLnu4Tnu4fmnrbmnoQiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.zTp3Ydz53BLNT647RBjxQ3XvOeZn_MprYEyoJxMb2zk&zhida_source=entity)：

  ![[assets/Pasted image 20250904060449.png]]


这个工作方式敏捷的很不彻底，问题在于运维。考虑到线上稳定性及系统的耦合程度，无法将运维拆到各个团队中去，各个产品线虽然有独立的产品经理、设计师和开发者，但需要运维协助上线测试环境，再由测试进行 testing 和 staging 两个环境进行测试验收。大量的时间被无用的等待浪费掉了。

![[assets/Pasted image 20250904060523.png]]
同时，由于工作目的的不同，开发与运维的矛盾也日益加深，都觉得对方基础的工作没有完成。 团队陷入了困境。

## **我们需要 DevOps**

困境中酝酿着机会，我们在与用户的交流中发现这也是大多数团队的共同苦恼：**团队如何组织才能最大化的进行软件产出？**各个角色之间天然的目标不同，使得”又快又好的上线“变得困难重重。

DevOps 的理念就是希望能打破这种屏障，**让研发（Development）和运维（Operations）一体化，让团队从业务需求出发，向着同一个目标前进**。DevOps 不只是通过工具辅助开发完成运维的部分工作，更是一种软件研发管理的思想、[方法论](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E6%96%B9%E6%B3%95%E8%AE%BA&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLmlrnms5XorroiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.djPyFNrldsPYgvYwhhTeyNxOw_Z0AVu-BH48Y5YxQCM&zhida_source=entity)，所追求的是一种没有隔阂的理想的研发协作状态。

  ![[assets/Pasted image 20250904060543.png]]

实践 DevOps 的首要任务是需要对 DevOps 的目标和精神达成共识，并以此指导工作。据此，我们制定了从新的产品线开始逐步拆分[微服务](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E5%BE%AE%E6%9C%8D%E5%8A%A1&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLlvq7mnI3liqEiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.uPNppNYc4zzjcZvnwBuHJp0xyQq7x3-kSFuWDDxu7W4&zhida_source=entity)、优化白名单验收机制等改进措施，并制定了明确的时间表。长期来看，希望在更好的保证软件质量的同时，开发更少的依赖运维工作。

![[assets/Pasted image 20250904060612.png]]

之后，团队开始尝试放大工具带来的效能提升。虽然之前也使用了不少工具，比如用 Jenkins 在本地构建持续集成，自建 Docker Registry 做构建物管理，使用 Excel 进行测试管理等。但相对零散，培训成本高，同时需要有人力进行选型搭建和维护，哪怕只放半个开发半个[运维](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=8&q=%E8%BF%90%E7%BB%B4&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLov5Dnu7QiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6OCwiemRfdG9rZW4iOm51bGx9.KMr1ZsJ3JyoGBzyngKtnJR5DB9P3FkoNUIQbFSV116E&zhida_source=entity)，一年也是小几十万的投入。

我们迫切的需要一套工具，上手即用，辅助我们提升研发团队的产出效能，而不是花费人力时间在进行基础设施的搭建上，但市面上完全没有这样的产品，我们的用户也存在类似的苦恼，只能用好几种开源产品进行搭建。

那 CODING 为什么不做一套这样的系统，让有同样困难的 DevOps 转型企业可以快速完成工具建设？“让开发更简单”作为 CODING 一直以来的使命和愿景，督促 CODING 团队为开发者提供更优质的工具与服务。加之 CODING 的核心业务——代码托管是 DevOps 工具的基础与支点，故从 2018 年年初起，CODING 就将产品目标调整至为企业提供一整套的研发管理工具。在一年多的努力下，**目前 CODING 已经全面开放持续集成功能及制品库的 SaaS 版本的服务，支持所有主流语言以及多种目标环境。**

![[assets/Pasted image 20250904060624.png]]

## **DevOps [开发工具](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E5%BC%80%E5%8F%91%E5%B7%A5%E5%85%B7&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLlvIDlj5Hlt6XlhbciLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.ME7CwghTIJ0YLK6xaQyKU9nCJohsVfsAq0wLA7NTxFM&zhida_source=entity)链：代码即应用**

我们认为，在不远的将来，随着工具的成熟，我们将进入**”代码即应用“（Code as a Product）**的时代，开发者无需进行繁杂的其他工作，仅需完成代码编写，应用就自动运行，企业因此降低了运维成本，提升了软件研发部门的效率。

"代码即应用”对工具的要求分三个阶段：

1. **持续集成阶段**：通过持续集成工具，运行设置好的执行命令，避免重复劳动。
2. **自动化部署阶段**：构建的创建过程本身变得简单，无需学习额外的运维开发知识即可创建应用的发布方式。
3. **Serverless 阶段**：真正做到发布无感知，代码写下即发布。

CODING 2.0 上线了持续集成及制品库的功能，标志着 CODING 正式进入[持续集成](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=6&q=%E6%8C%81%E7%BB%AD%E9%9B%86%E6%88%90&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLmjIHnu63pm4bmiJAiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6NiwiemRfdG9rZW4iOm51bGx9.Bbb2GKilBD6FwBYMTMyc6SQDI5wMcfE2LFj-_Kd36Rc&zhida_source=entity)阶段。用户仅需推送代码或合并请求，即可出发持续集成进行构建、单元测试、安全扫描等工作，并生成制品存储[在制品](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E5%9C%A8%E5%88%B6%E5%93%81&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLlnKjliLblk4EiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.83uJEv0-A-KCgvbSyuT7NN7ydFfDYBQcw1-gkX4an9Y&zhida_source=entity)库。提升软件交付的质量与速度，同时减少因为构建过程中引入”人“而带来的不确定性。

![[assets/Pasted image 20250904060637.png]]

除工具外，CODING 还为企业提供研发流程实施的指导培训、[敏捷训练](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E6%95%8F%E6%8D%B7%E8%AE%AD%E7%BB%83&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLmlY_mjbforq3nu4MiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.5pcQZ0OhcWykwICpGisq-AjqspYyqoZ30eZgt0rRtnc&zhida_source=entity)等额外服务。目前已有几十家企业将 CODING 的 DevOps 工具应用到内部生产中，大大提升了团队 DevOps 转型的效率。

## **还有点想说的**

[中国软件](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E4%B8%AD%E5%9B%BD%E8%BD%AF%E4%BB%B6&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLkuK3lm73ova_ku7YiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.xX_quOV8tKDDmjVbOOP9RbwhFlzvvvu4yKFn7-lCd60&zhida_source=entity)行业发展时间短，发展速度快，[人才储备](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E4%BA%BA%E6%89%8D%E5%82%A8%E5%A4%87&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLkurrmiY3lgqjlpIciLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.qm4zQtxRo1yliYmh_xYKOOU5BYKDIx_YOk2QmEiDsKI&zhida_source=entity)时间短，地位也比较尴尬，哪怕是软件服务起家的互联网公司，随着公司的壮大，业务部门的地位也逐渐高于软件研发部门。除了在少量领域，[中国企业](https://zhida.zhihu.com/search?content_id=103912741&content_type=Article&match_order=1&q=%E4%B8%AD%E5%9B%BD%E4%BC%81%E4%B8%9A&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NTY5OTQ2NDYsInEiOiLkuK3lm73kvIHkuJoiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoxMDM5MTI3NDEsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.UN0ZUKNCMqVwr3pu9uG1BuPj7Y3R10Jp1ocqGHBU9W0&zhida_source=entity)在这一过程中，研发部门的内驱力往往被消磨殆尽。加之软件行业人力成本不断增加，作为支持和成本部门，管理者也容易将软件研发部门视为成本部门，思路往往是“能否降低成本“。

但如今，瞬息万变的市场环境对软件研发部门提出了很高的挑战，这是困难但也是机会。**一支高效的研发团队，不光可以减少系统间的摩擦和浪费，让研发部门快速响应市场需求，还可以持续交付高标准的产品，让产品验证进入正循环，引领整个团队的价值实现。**

但组建一支这样的团队，需要的远不止是工具，更重要的是团队领导者的经验，知识，和变化的决心。许多有先锋精神的团队走在改革的前面，CODING 在协助他们转型的过程中，也看到了他们因为改革所碰到的困难、权衡和进步之后团队爆发出的生产力。

我们希望可以看到更多的中国软件企业了解 DevOps 的精神，并应用到自己的团队管理中去，向中国和世界交付一流的软件产品。这个过程很难，但真的很值得。

