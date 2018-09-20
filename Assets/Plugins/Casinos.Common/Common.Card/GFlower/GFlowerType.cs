// Copyright(c) Cragon. All rights reserved.

namespace Casinos
{
    //-------------------------------------------------------------------------
    public enum HandRankTypeGFlowerH
    {
        HighCard = 0,
        Pair,
        Straight,
        Flush,
        StraightFlush,
        BaoZi,
        RoyalBaoZi,
    }

    //-------------------------------------------------------------------------
    public enum HandRankTypeGFlower
    {
        HighCard = 0,
        Pair,
        Straight,
        Flush,
        StraightFlush,
        BaoZi,
    }

    //-------------------------------------------------------------------------
    // ����
    public enum PlayerActionTypeGFlower
    {
        None = 0,// �޲���   
        Bet = 1,// �µ�ע
        Fold = 2,// ����
        SeeCard = 3, // ����
        Call = 4,// ��ע
        Raise = 5,// ��ע   
        FireRaise = 6,// ��ƴ��ע
        PKCard = 7// ����        
    }
}