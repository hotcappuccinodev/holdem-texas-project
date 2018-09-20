// Copyright(c) Cragon. All rights reserved.

namespace Casinos
{
    //-------------------------------------------------------------------------
    public enum MaJiangType
    {
        One = 1,
        Two = 2,
        Three = 3,
        Four = 4,
        Five = 5,
        Six = 6,
        Seven = 7,
        Eight = 8,
        Nine = 9,
        DongFeng = 10,
        NanFeng = 11,
        XiFeng = 12,
        BeiFeng = 13,
        Bai = 14,
        Zhong = 15,
        Fa = 16,
    }

    //-------------------------------------------------------------------------
    public enum MaJiangSuit : byte
    {
        Wan = 0,// ��
        Tong = 1,// ��
        Tiao = 2,// ��
        DongFeng = 3,// ����
        NanFeng = 4,// �Ϸ�
        XiFeng = 5,// ����
        BeiFeng = 6,// ����            
        Bai = 7,// �װ�
        Zhong = 8,// ����    
        Fa = 9,// ����
    }

    //-------------------------------------------------------------------------
    public enum HandRankTypeZhongFB
    {
        Dian0 = 0,
        Dian1,
        Dian2,
        Dian3,
        Dian4,
        Dian5,
        Dian6,
        Dian7,
        Dian8,
        Dian9,
        BaoZi,
        BaoZiBai,
        BaoZiZhong,
        BaoZiFa,
        TianGang,
    }
}