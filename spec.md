Gringotts
---------

Gringotts 是一个 Nervos CKB 租赁平台。CKB Holder 若不满足 NervosDAO 的收益的话，可以把币租出来；然后假设想做 dapp 的开发者或其他人，需要很多币，又不想一次投入买，他们就可以商量形成租约。租约实际就是一个用特殊 lock 合约的 cell，租借者只要按月给大户的地址打利息（比如假设年化 5% 的利息），就可以持续用这个 cell 存自己需要的内容，而如果开发者没按时付息（或者破产了不做了），出租者就可以把 cell 收回，CKB 用作他用。

## Users

a) 租借者需要看到自己租了哪些 cell，最近马上要到租期的 cell 有哪些，要付多少钱，最好能 UI 里再一键支付；

b) 出租者需要看到自己租出了多少 cell，下次租期到期是什么时候，能获得的年化收益有多少，我还有多少 CKB 可以租。

扩展功能：租赁平台之类的，双方都可以发广告，达成协议之后开租。


## API

1. 给地址拿自己租到的 cell
1. 给地址拿自己租出去的 cell
1. 出租者创建发租出 cell 的 transaction
1. 出租者发收回没按期支付的 cell 的 transaction
1. 租借者创建发 payment 的 transaction
1. 给 transaction 签名
