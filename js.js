const a = [1,2,3,3,4,52,4,52,32,2,3,1]
const b = []

for(let i=0;i<a.length;i++){
    if(!b.includes(a[i])){
        b.push(a[i])
    }
}
console.log(a)+
console.log(b)

for(let i =0;i<b.length;i++){
    a[i]=b[i]
}

// for(let i=0;i<b.length;i++){
//     console.log(a[i])
// }