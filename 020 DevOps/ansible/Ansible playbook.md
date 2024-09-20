# Ansible playbook

　　​`ansible`​命令每次只能执行一个任务，这种运行方式称为Ad-hoc(点对点模式)，不考虑Ansible特性的话，这功能比ssh远程执行命令还要弱。

　　所以，Ansible靠ansible命令是撑不起自动化管理这把大伞的，Ansible真正强大的是playbook，它才是Ansible撬动自动化管理的结实杠杆。

## 1. playbook、play和task的关系

　　在前面介绍inventory的时候，我将它类比为演员表，在这里，我继续对playbook、play和task跟拍电影中的一些过程做个对比。

　　playbook译为剧本，就像电影、电视剧的剧本一样，剧本中记录了电影的每一片段应该怎么拍，包括：拍之前场景布置、拍之后的清场、每一个演员说什么话做什么动作、每一个演员穿什么样的衣服，等等。

　　‍

　　Ansible的playbook也如此，电影的每一个片段可以对应于playbook中的每一个play，每一个play都可以有多个任务(tasks)，tasks可以对应于电影片段中的每一幕。所以，playbook可以用来组织多个任务，然后让这些任务统一执行，就像shell脚本组织多个命令一样，这种组织多个事件、多个任务的行为，有一个更高大上的术语：”编排”。

　　还可以继续更细致的对应起来。比如每一个play都可以定义自己的环境，比如play级别的变量，对应于电影片段的场景布置，每一个play都需要指定要执行该play的主机，即先确定好这个电影片段中涉及的演员，每一个Play可以有pre\_tasks，对应于正式开拍之前的布置，每一个play可以有post\_tasks，对应于拍完之后的清场。

　　而我们人，既是编写playbook的编剧，也是让playbook跑起来的导演。

　　简单总结一下playbook、play和task的关系：

1. playbook中可以定义一个或多个play
2. 每个play中可以定义一个或多个task

* 其中还可以定义两类特殊的task：pre\_tasks和post\_tasks
* pre\_tasks表示执行执行普通任务之前执行的任务列表
* post\_tasks表示普通任务执行完之后执行的任务列表

3. 每个play都需要通过hosts指令指定要执行该play的目标主机
4. 每个play都可以设置一些该play的环境控制行为，比如定义play级别的变量

　　如图：

​![](https://www.junmajinlong.com/img/ansible/1576207589367.png)​

　　例如，下面是一个playbook示例，文件名为first.yml，内容如下：

```
---
- name: play 1
  hosts: nginx
  gather_facts: false
  tasks: 
    - name: task1 in play1
      debug: 
        msg: "output task1 in play1"

    - name: task2 in play1
      debug: 
        msg: "output task2 in play1"

- name: play 2
  hosts: apache
  gather_facts: false
  tasks: 
    - name: task1 in play2
      debug: 
        msg: "output task1 in play2"

    - name: task2 in play2
      debug: 
        msg: "output task2 in play2"
```

　　先不管这个playbook中的内容具体是什么含义，后面会为大家介绍playbook的写法。不过，我想大家从名称或从缩进级别上大致也能看出这个playbook中包含两个play：”play 1”和”play 2”，每个play中又包含了两个task。且执行”play 1”的是nginx主机组中的主机节点，执行”play  2”的是apache主机组中的主机节点。

　　使用ansible-playbook命令执行这个playbook：

```
$ ansible-playbook first.yml
```

　　输出结果：

```
PLAY [play 1] **************************

TASK [task1 in play1] ******************
ok: [192.168.200.27] => {
    "msg": "output task1 in play1"
}
ok: [192.168.200.28] => {
    "msg": "output task1 in play1"
}
ok: [192.168.200.29] => {
    "msg": "output task1 in play1"
}

TASK [task2 in play1] ******************
ok: [192.168.200.27] => {
    "msg": "output task2 in play1"
}
ok: [192.168.200.28] => {
    "msg": "output task2 in play1"
}
ok: [192.168.200.29] => {
    "msg": "output task2 in play1"
}

PLAY [play 2] **************************

TASK [task1 in play2] ******************
ok: [192.168.200.30] => {
    "msg": "output task1 in play2"
}
ok: [192.168.200.31] => {
    "msg": "output task1 in play2"
}
ok: [192.168.200.32] => {
    "msg": "output task1 in play2"
}
ok: [192.168.200.33] => {
    "msg": "output task1 in play2"
}

TASK [task2 in play2] ******************
ok: [192.168.200.30] => {
    "msg": "output task2 in play2"
}
ok: [192.168.200.31] => {
    "msg": "output task2 in play2"
}
ok: [192.168.200.32] => {
    "msg": "output task2 in play2"
}
ok: [192.168.200.33] => {
    "msg": "output task2 in play2"
}

PLAY RECAP ****************************
192.168.200.27  : ok=2  changed=0  ......
192.168.200.28  : ok=2  changed=0  ......
192.168.200.29  : ok=2  changed=0  ......
192.168.200.30  : ok=2  changed=0  ......
192.168.200.31  : ok=2  changed=0  ......
192.168.200.32  : ok=2  changed=0  ......
192.168.200.33  : ok=2  changed=0  ......
```

　　输出结果有点长，但是初学playbook，有必要了解一下输出结果中一些内容的含义。

　　首先执行的是playbook中的`"play 1"`​，nginx主机组(有3个节点)要执行这个play，且这个play中有两个任务要执行，所以输出结果为：

```
PLAY [play 1] **************************

TASK [task1 in play1] ******************
ok: [192.168.200.27] => {}
ok: [192.168.200.28] => {}
ok: [192.168.200.29] => {}

TASK [task2 in play1] ******************
ok: [192.168.200.27] => {}
ok: [192.168.200.28] => {}
ok: [192.168.200.29] => {}
```

　　其中ok表示任务执行成功，且PLAY和TASK后面都指明了play的名称、task的名称。

　　执行完`"play 1"`​之后，执行`"play 2"`​，apache主机组(有3个节点)要执行这个play，且这个play中有两个任务要执行，所以输出的输出结果和上面的类似。

　　最后输出的是每个主机执行任务的状态统计，比如某个主机节点执行成功的任务有几个，失败的有几个。

```
PLAY RECAP ****************************
192.168.200.27  : ok=2  changed=0  ......
192.168.200.28  : ok=2  changed=0  ......
192.168.200.29  : ok=2  changed=0  ......
192.168.200.30  : ok=2  changed=0  ......
192.168.200.31  : ok=2  changed=0  ......
192.168.200.32  : ok=2  changed=0  ......
192.168.200.33  : ok=2  changed=0  ......
```

　　介绍完playbook并演示完它的用法之后，接下来该学playbook的写法了。

## 2. playbook的语法：YAML

　　ansible的playbook采用yaml语法，它以非常简洁的方式实现了json格式的事件描述。yaml之于json就像markdown之于html一样，极度简化了json的书写。

　　YAML文件后缀通常为`.yaml`​或`.yml`​。

　　YAML在不少工具里都使用，学习它是”一次学习、终生受益”的，所以很有必要把yaml的语法格式做个梳理，系统性地去学一学。

　　YAML的基本语法规则如下：

* 使用缩进表示层级关系
* 缩进时不允许使用Tab键，只允许使用空格
* 缩进的空格数目不重要，只要相同层级的元素左对齐即可
* yaml文件以“——”作为文档的开始，以表明这是一个yaml文件

  即使没有使用———开头，也不会有什么影响
* #表示注释，从这个字符一直到行尾，都会被解析器忽略
* 字符串不用加引号，但在可能产生歧义时，需加引号（单双引号皆可）
* 布尔值非常灵活，不区分大小写的true/false、yes/no、on/off、y/n、0和1都允许

　　YAML支持三种数据结构：

* 对象：key/value格式，也称为哈希结构、字典结构或关联数组
* 数组：也称为列表
* 标量(scalars)：单个值

　　可以去找一些在线YAML转换JSON网站，比如[http://yaml-online-parser.appspot.com](https://yaml-online-parser.appspot.com/)，通过在线转换可以验证或查看自己所写的YAML是否出错以及哪里出错。也可以安装yq(yaml query)命令将yaml数据转换成json格式数据。

```
yum -y install jq
pip3 install yq
```

　　用法：

```
cat a.yml | yq .
```

### 2.1 对象

　　一组键值对，使用冒号隔开key和value。注意，**冒号后必须至少一个空格**。

```
name: junmajinlong
```

　　等价于json：

```
{
  "name": "junmajinlong"
}
```

### 2.2 数组

```
---
- Shell
- Perl
- Python
```

　　等价于json：

```
["Shell","Perl","Python"]
```

　　也可以使用行内数组(内联语法)的写法：

```
---
["Shell","Perl","Python"]
```

　　再例如：

```
---
- lang1: Shell
- lang2: Perl
- lang3: Python
```

　　等价于json：

```
[
  {"lang1": "Shell"}, 
  {"lang2": "Perl"}, 
  {"lang3": "Python"}
]
```

　　将对象和数组混合：

```
---
languages:
  - Shell
  - Perl
  - Python
```

　　等价于json：

```
{
  "languages": ["Shell","Perl","Python"]
}
```

### 2.3 字典

```
---
person1:
  name: junmajinlong
  age: 18
  gender: male

person2:
  name: xiaofanggao
  age: 19
  gender: female
```

　　等价于json：

```
{
  "person2": {
    "gender": "female", 
    "age": 19, 
    "name": "xiaofanggao"
  }, 
  "person1": {
    "gender": "male", 
    "age": 18, 
    "name": "junmajinlong"
  }
}
```

　　也可以使用行内对象的写法：

```
---
person1: {name: junmajinlong, age: 18, gender: male}
```

### 2.4 复合结构

```
---
- person1:
  name: junmajinlong
  age: 18
  langs:
    - Perl
    - Ruby
    - Shell

- person2:
  name: xiaofanggao
  age: 19
  langs:
    - Python
    - Javascript
```

　　等价于json：

```
[
  {
    "langs": [
      "Perl", 
      "Ruby", 
      "Shell"
    ], 
    "person1": null, 
    "age": 18, 
    "name": "junmajinlong"
  }, 
  {
    "person2": null, 
    "age": 19, 
    "langs": [
      "Python", 
      "Javascript"
    ], 
    "name": "xiaofanggao"
  }
]
```

### 2.5 字符串续行

　　字符串可以写成多行，从第二行开始，必须至少有一个单空格缩进。换行符会被转为空格。

```
str: hello
  world
  hello world
```

　　等价于json：

```
{
  "str": "hello world hello world"
}
```

　　也可以使用`>`​换行，它类似于上面的多层缩进写法。此外，还可以使用`|`​在换行时保留换行符。

```
this: |
  Foo
  Bar
that: >
  Foo
  Bar
```

　　等价于json：

```
{'that': 'Foo Bar', 'this': 'Foo\nBar\n'}
```

### 2.6 空值

　　YAML中某个key有时候不想为其赋值，可以直接写key但不写value，另一种方式是直接写null，还有一种比较少为人知的方式：波浪号`~`​。

　　例如，下面几种方式全是等价的：

```
key1: 
key2: null
key3: Null
key4: NULL
key5: ~
```

### 2.7 YAML中的单双引号和转义

　　YAML中的字符串是可以不用使用引号包围的，但是如果包含了特殊符号，则需要使用引号包围。

　　单引号包围字符串时，会将特殊符号保留。

　　双引号包围字符串时，反斜线需要额外进行转义。

　　例如，下面几对书写方式是等价的：

```
- key1: "~"
- key2: '~'

- key3: '\.php$'
- key4: "\\.php$"
- key5: \.php$

- key6: \n
- key7: '\n'
- key8: "\\n"
```

　　等价于json：

```
[
  { "key1": "~" },
  { "key2": "~" },
  { "key3": "\\.php$" },
  { "key4": "\\.php$" },
  { "key5": "\\.php$" },
  { "key6": "\\n" },
  { "key7": "\\n" },
  { "key8": "\\n" }
]
```

## 3. playbook的写法

　　了解YAML写法之后，就可以来写Ansible的playbook了。

　　回顾一下前文对playbook、play和task关系的描述，playbook可以包含一个或多个play，每个play可以包含一个或多个任务，且每个play都需要指定要执行该play的目标主机。

　　于是，将下面这个ad-hoc模式的ansible任务改成等价的playbook模式：

```
$ ansible nginx -m copy -a 'src=/etc/passwd dest=/tmp'
```

　　假设这个playbook的文件名为copy.yml，其内容如下：

```
---
- hosts: nginx
  gather_facts: false

  tasks: 
    - copy: src=/etc/passwd dest=/tmp
```

　　然后使用ansible-playbook命令执行该playbook。

```
$ ansible-playbook copy.yml
```

　　再来解释一下这个playbook文件的含义。

　　playbook中，每个play都需要放在数组中，所以在playbook的顶层使用列表的方式`- xxx:`​来表示这是一个play（此处是`- hosts:`​）。

　　每个play都必须包含`hosts`​和`tasks`​指令。

　　​`hosts`​指令用来指定要执行该play的目标主机，可以是主机名，也可以是主机组，还支持其它方式来更灵活的指定目标主机。具体的规则后文再做介绍。

　　​`tasks`​指令用来指定这个play中包含的任务，可以是一个或多个任务，任务也需要放在play的数组中，所以`tasks`​指令内使用`- xxx:`​的方式来表示每一个任务（此处是`- copy: `​）。

　　​`gather_facts`​是一个play级别的指令设置，它是一个负责收集目标主机信息的任务，由setup模块提供。默认情况下，每个play都会先执行这个特殊的任务，收集完信息之后才开始执行其它任务。但是，收集目标主机信息的效率很低，如果能够确保playbook中不会使用到所收集的信息，可以显式指定`gather_facts: no`​来禁止这个默认执行的收集任务，这对效率的提升是非常可观的。

　　此外每个play和每个task都可以使用`name`​指令来命名，也建议尽量为每个play和每个task都命名，且名称具有唯一性。

　　所以，将上面的playbook改写：

```
---
- name: first play
  hosts: nginx
  gather_facts: false

  tasks: 
    - name: copy /etc/passwd to /tmp
      copy: src=/etc/passwd dest=/tmp
```

## 4. playbook模块参数的传递方式

　　在刚才的示例中，copy模块的参数传递方式如下：

```
tasks: 
  - name: copy /etc/passwd to /tmp
    copy: src=/etc/passwd dest=/tmp
```

　　这是标准的yaml语法，参数部分`src=/etc/passwd dest=/tmp`​是一个字符串，当作copy对应的值。

　　根据前面介绍的yaml语法，还可以换行书写。有以下几种方式：

```
---
- name: first play
  hosts: nginx
  gather_facts: false
  tasks: 
    - copy: 
        src=/etc/passwd dest=/tmp

    - copy: 
        src=/etc/passwd
        dest=/tmp

    - copy: >
        src=/etc/passwd
        dest=/tmp

    - copy: |
        src=/etc/passwd
        dest=/tmp
```

　　除此之外，Ansible还提供了另外两种传递参数的方式：

* 将参数和参数值写成`key: value`​的方式
* 使用`args`​参数声明接下来的是参数

　　通过示例便可对其用法一目了然：

```
---
- name: first play
  hosts: nginx
  gather_facts: false
  tasks: 
    - name: copy1
      copy: 
        src: /etc/passwd
        dest: /tmp

    - name: copy2
      copy: 
      args:
        src: /etc/passwd
        dest: /tmp
```

　　大多数时候，使用何种方式传递参数并无关紧要，只要个人觉得可读性高、方便、美观即可。

## 5. 指定执行play的目标主机

　　每一个play都包含`hosts`​指令，它用来指示在解析inventory之后选择哪些主机执行该play中的tasks。

　　​`hosts`​指令通过pattern的方式来筛选节点，pattern的指定方式有以下几种规则：

1. 直接指定inventory中定义的主机名

* ​`hosts: localhost`​

2. 直接指定inventory中的主机组名

* ​`hosts: nginx`​
* ​`hosts: all`​

3. 使用组名时，可以使用数值索引的方式表示组中的第几个主机

* ​`hosts: nginx[1]:mysql[0]`​

4. 可使用冒号或逗号隔开多个pattern

* ​`hosts: nginx:localhost`​

5. 可以使用范围表示法

* ​`hosts: 192.168.200.3[0:3]`​
* ​`hosts: web[A:D]`​

6. 可以使用通配符`*`​

* ​`hosts: *.example.com`​
* ​`hosts: *`​，这等价于`hosts: all`​

7. 可以使用正则表达式，需使用`~`​开头

* ​`hosts: ~(web|db)\.example\.com`​

　　此外：

1. 所有pattern选中的主机都是包含性的，第一个pattern选中的主机会添加到下一个pattern的范围内，直到最后一个pattern筛选完，于是取得了所有pattern匹配的主机
2. pattern前面加一个`&`​符号表示取交集

* ​`pattern1:&pattern2`​要求同时存在于pattern1和pattern2中的主机

3. pattern前面加一个`!`​符号表示排除

* ​`pattern1:!pattern2`​要求出现在pattern1中但未出现在pattern2中

## 6. 默认的任务执行策略

　　最后，再来简单探究一下默认情况下Ansible是以什么样的策略去控制多个节点执行多个任务的(如果你愿意，还可以将这个执行策略跟拍戏进行类比，我就不再多说了，毕竟我是IT攻城狮不是编剧也不是导演啊)。

　　假设有10个目标节点要执行某个play中的3个任务：tA、tB、tC。

　　默认情况下，会从10个目标节点中选择5个节点作为第一批次的节点执行任务tA，第一批次的5个节点都执行tA完成后，将选择剩下的5个节点作为第二批次执行任务tA。

　　所有节点都执行完任务tA后，第一批次的5节点开始执行任务tB，然后第二批次的5个节点执行任务tB。

　　所有节点都执行完任务tB后，第一批次的5节点开始执行任务tC，然后第二批次的5个节点执行任务tC。

　　整个过程如下：

　　​![](https://www.junmajinlong.com/img/ansible/1576213846.gif)[https://www.junmajinlong.com/img/ansible/1576213846.gif](https://www.junmajinlong.com/img/ansible/1576213846.gif)

　　这个流程图虽然简单形象，但是不严谨，稍后会解释为何不严谨。

　　这里提到的5个节点的数量5，是由配置文件中forks指令的值决定的，默认值为5。

```
$ grep 'fork' /etc/ansible/ansible.cfg
#forks          = 5
```

　　forks指令用来指定Ansible最多要创建几个子进程来执行任务，每个节点默认对应一个ansible-playbook进程和ssh进程，例如forks\=5表示最多创建5个ansible-playbook子进程。所以，forks的值也代表了最多有几个节点同时执行任务。

　　例如，将hosts指令指定为all，并将`gather_facts`​指令取消注释，因为这个任务执行比较慢，方便观察进程列表。

```
---
- name: first play
  hosts: all 
  #gather_facts: false
```

　　执行该playbook。

```
$ ansible-playbook test.yaml
```

　　然后在另外一个终端上去查看进程列表：

​![](https://www.junmajinlong.com/img/ansible/1625968925519.png)​

　　根据上面对forks指令的效果描述，前面的执行策略流程图并不严谨。因为forks的效果并不是选中一批节点，本批节点执行完任务才选下一批节点。forks是保证最多有N个节点同时执行任务，但有的节点可能执行任务较慢。比如有10个节点，且forks\=5时，第一批选中5个节点执行任务，假如第1个节点先执行完任务，Ansible主控进程不会等待本批中其它4个节点执行完任务，而是直接创建一个新的Ansible进程，让第6个节点执行任务。

　　‍

　　文章作者: [骏马金龙](https://www.junmajinlong.com)

　　文章链接: [https://junmajinlong.github.io/ansible/4_ansible_soul_playbook/](https://junmajinlong.github.io/ansible/4_ansible_soul_playbook/)
