﻿//using Casinos;
//using System;
//using System.Collections.Generic;
//using UnityEngine;

//public class WWWAsyncLoader
//{
//    //-------------------------------------------------------------------------
//    AsyncAssetLoaderMgr AsyncAssetLoaderMgr { get; set; }
//    Dictionary<string, UnityEngine.Networking.UnityWebRequest> MapWWW { get; set; }
//    Dictionary<string, UnityEngine.Networking.UnityWebRequest> MapWWWIsDone { get; set; }
//    Dictionary<string, Action<string, UnityEngine.Networking.UnityWebRequest>> MapLoaderTicketAndCallBack { get; set; }

//    //WWW mAsyncAssetWWW;
//    //List<LoaderTicket> ListCallBackDoneTicket { get; set; }

//    //-------------------------------------------------------------------------
//    public WWWAsyncLoader(AsyncAssetLoaderMgr mgr)
//    {
//        AsyncAssetLoaderMgr = mgr;
//        MapWWW = new Dictionary<string, UnityEngine.Networking.UnityWebRequest>();
//        MapWWWIsDone = new Dictionary<string, UnityEngine.Networking.UnityWebRequest>();
//        MapLoaderTicketAndCallBack = new Dictionary<string, Action<string, UnityEngine.Networking.UnityWebRequest>>();

//        //ListCallBackDoneTicket = new List<LoaderTicket>();
//    }

//    //-------------------------------------------------------------------------
//    public void Close()
//    {
//        MapWWW.Clear();
//        MapWWWIsDone.Clear();
//        MapLoaderTicketAndCallBack.Clear();
//    }

//    //-------------------------------------------------------------------------
//    public void update(float tm)
//    {
//        foreach (var i in MapWWW)
//        {
//            UnityEngine.Networking.UnityWebRequest www = i.Value;
//            if (www != null)
//            {
//                if (www.isDone)
//                {
//                    MapWWWIsDone[i.Key] = i.Value;
//                }
//            }
//        }

//        foreach (var i in MapWWWIsDone)
//        {
//            MapWWW.Remove(i.Key);
//            Action<string, UnityEngine.Networking.UnityWebRequest> ticketandcallback = null;
//            if (MapLoaderTicketAndCallBack.TryGetValue(i.Key, out ticketandcallback))
//            {
//                ticketandcallback(i.Key, i.Value);
//                MapLoaderTicketAndCallBack.Remove(i.Key);

//                //foreach (var ticket in map_ticketandcallback)
//                //{
//                //    ticket.Value(i.Key, i.Value);
//                //    ListCallBackDoneTicket.Add(ticket.Key);
//                //}

//                //foreach (var callback_done_ticket in ListCallBackDoneTicket)
//                //{
//                //    map_ticketandcallback[callback_done_ticket] = null;
//                //}
//                //ListCallBackDoneTicket.Clear();
//            }
//            i.Value.Dispose();
//        }

//        MapWWWIsDone.Clear();
//    }

//    //-------------------------------------------------------------------------
//    public LoaderTicket getIsDoneWWW(string asset_path, Action<string, UnityEngine.Networking.UnityWebRequest> www_isdone_callback)
//    {
//        LoaderTicket loader_ticket = null;
//        UnityEngine.Networking.UnityWebRequest www = null;
//        if (MapWWWIsDone.TryGetValue(asset_path, out www))
//        {
//            if (www.isDone)
//            {
//                www_isdone_callback(asset_path, www);
//            }
//            else
//            {
//                loader_ticket = new LoaderTicket();
//                Action<string, UnityEngine.Networking.UnityWebRequest> ticketandcallback = null;
//                if (!MapLoaderTicketAndCallBack.TryGetValue(asset_path, out ticketandcallback))
//                {
//                    ticketandcallback = www_isdone_callback;
//                    MapLoaderTicketAndCallBack[asset_path] = ticketandcallback;
//                }
//                else
//                {
//                    ticketandcallback += www_isdone_callback;
//                }
//                //map_ticketandcallback[loader_ticket] = www_isdone_callback;
//            }
//        }
//        else
//        {
//            loader_ticket = new LoaderTicket();
//            www = new UnityEngine.Networking.UnityWebRequest(CasinoHelper.FormalUrlWithRandomVersion(asset_path));
//            MapWWW[asset_path] = www;
//            Action<string, UnityEngine.Networking.UnityWebRequest> ticketandcallback = null;
//            if (!MapLoaderTicketAndCallBack.TryGetValue(asset_path, out ticketandcallback))
//            {
//                ticketandcallback = www_isdone_callback;
//                MapLoaderTicketAndCallBack[asset_path] = ticketandcallback;
//            }
//            else
//            {
//                ticketandcallback += www_isdone_callback;
//            }
//        }

//        return loader_ticket;
//    }
//}