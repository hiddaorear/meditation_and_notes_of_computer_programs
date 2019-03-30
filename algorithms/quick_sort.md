# 快排

## 简介

又称划分交换排序(partition-exchange sort)，简称快排。由车尼·霍尔提出。平均状态下，排序n个项目，需要O(nlogn)次比较，最坏的情况要O(n^2)次比较。

快速排序通常明显比其他算法快，因为其内部循环可以在大部分架构上有效率的达成。

## 算法的退化

退化一般是指算法性能的稳定性。快排对于有序的数据，会退化为冒泡排序的复杂度O(n^2)。

## 算法的稳定性

稳定性排序算法会让原本相等键值的记录，维持相对的次序。如果一个排序算法稳定，则两个相等的键值的记录R和S，在原本的列表中R出现在S之前，在排序之后，R也会在S之前。

假设要将数对已他们的第一个数字来排序：

`(4,1)(3,1)(3,7)(5,6)`

排序之后可能有两个结果：

`(3,1)(3,7)(4,1)(5,6)` 维持次序，稳定
`(3,1)(4,1)(3,7)(5,6)` 次序被改变，不稳定

## 代码实现

```` javascript

function quickSort(arr) {
    if (!arr || arr.length === 1) {
        return arr;
    }
    let right = [];
    let left = [];
    let pivot = arr[arr.length >> 1 || 0];
    arr.forEach(item => {
        item >= pivot ? right.push(item) : left.push(item);
    });
    return [...quickSort(left), pivot, ...quickSort(right)];
}

````


## 参考资料

[快速排序wiki](https://zh.wikipedia.org/wiki/%E5%BF%AB%E9%80%9F%E6%8E%92%E5%BA%8F)

[排序算法](https://zh.wikipedia.org/wiki/%E6%8E%92%E5%BA%8F%E7%AE%97%E6%B3%95)
