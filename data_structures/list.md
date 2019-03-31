# 计算机基础

## 链表

### 检测单向链表存在环

链表定义：

```` c
struct Node{
    int data;
    Node* next;
};
````

#### 1

对访问过的元素，做标记。遇到已标记的元素，则说明链表存在环。

评论：其实这是一个显而易见的答案，但很少能想到，一般不会想着去修改链表。

#### 2

逐个访问元素，存储在数组或散列表中，检查后续元素是否存在其中。

评论：很多人，初次会想到的答案。

#### 3

限制：内存有限，无额外空间创建数组。

设置一个指针p1，指向链表头部。设置另一个指针p2，访问剩余N-1个元素，并比较。然而，移动p1到第二个元素，与剩余的N-2个元素比较。以此类推。比较都不相等，则不存环。

#### 4

限制：如果链表非常长

快慢指针。

```` c
bool hasCircle(Node *head, Node *&circleNode)
{
    if(head == NULL || head->next == NULL) return NULL;

    Node *slow, *fast;
    show = fast = head;
    while(fast->next != NULL)
    {
        fast = fast->next->next;
        slow = slow->next;
        if (fast == slow)
        {
            circleNode = fast;
            return true;
        }

    }
    return false;
}

````

#### 5 找到环入口

假定起点到环入口点的距离为 a，p1 和 p2 的相交点M与环入口点的距离为b，环路的周长为L，当 p1 和 p2 第一次相遇的时候，假定 p1 走了 n 步。那么有：

p1走的路径： `a+b ＝ n`；
p2走的路径： `a+b+k*L = 2*n`； p2 比 p1 多走了k圈环路，总路程是p1的2倍

根据上述公式可以得到
`k*L=a+b=n`，也就是`k*L-b=a`。可以这么理解，从起点到环入口a的距离，可以表示为环的周长的倍数与相交点的差。

```` c
//找到环的入口点
Node* findLoopPort(Node *head)
{
    //如果head为空，或者为单结点，则不存在环
    if(head == NULL || head->next == NULL) return NULL;

    Node *slow,*fast;
    slow = fast = head;

    //先判断是否存在环
    while(fast != NULL && fast->next != NULL)
    {
        fast = fast->next->next;
        slow = slow->next;
        if(fast == slow)
            break;
    }

    if(fast != slow) return NULL;    //不存在环

    fast = head;                //快指针从头开始走，步长变为1
    while(fast != slow)            //两者相遇即为入口点
    {
        fast = fast->next;
        slow = slow->next;
    }

    return fast;
}

````

### 参考资料

《C专家编程》

[面试精选：链表问题集锦](http://wuchong.me/blog/2014/03/25/interview-link-questions/)
