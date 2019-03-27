package com.Cragon.ZeroPt.wxapi;

import com.ThirdPartyLogin.ThirdPartyLogin.ThirdPartyLogin;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelmsg.ShowMessageFromWX;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.tencent.mm.opensdk.modelmsg.WXAppExtendObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler{
	// IWXAPI �ǵ�����app��΢��ͨ�ŵ�openapi�ӿ�
    private IWXAPI api;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);        
        
        // ͨ��WXAPIFactory��������ȡIWXAPI��ʵ��
        String app_id = ThirdPartyLogin.Instantce.getAppId(); 
        Log.e("WXEntryActivity", "onCreate__"+app_id);
        
    	api = WXAPIFactory.createWXAPI(this, app_id, false);
		//ע�⣺
		//���������������ʹ��͸��������ʵ��WXEntryActivity����Ҫ�ж�handleIntent�ķ���ֵ���������ֵΪfalse��
    	//��˵����β��Ϸ�δ��SDK����Ӧfinish��ǰ͸�����棬�����ⲿͨ�����ݷǷ�������Intent����ͣ����͸�����棬�����û����ɻ�
        try {        	
        	api.handleIntent(getIntent(), this);
        } catch (Exception e) {
        	Log.e("WXEntryActivity", "onCreate__handleIntent_Error__"+e.getMessage());
        	e.printStackTrace();
        }
    }

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		
		setIntent(intent);
        api.handleIntent(intent, this);
	}

	// ΢�ŷ������󵽵�����Ӧ��ʱ����ص����÷���
	@Override
	public void onReq(BaseReq req) {
		Log.e("WXEntryActivity", "onReq__"+req.getType());
		switch (req.getType()) {
		case ConstantsAPI.COMMAND_GETMESSAGE_FROM_WX:
				
			break;
		case ConstantsAPI.COMMAND_SHOWMESSAGE_FROM_WX:
			ShowMessageFromWX.Req showReq= (ShowMessageFromWX.Req) req;
			WXMediaMessage wxMsg = showReq.message;		
			WXAppExtendObject obj = (WXAppExtendObject) wxMsg.mediaObject;
			
			StringBuffer msg = new StringBuffer(); // ��֯һ������ʾ����Ϣ����
			msg.append("description: ");
			msg.append(wxMsg.description);
			msg.append("\n");
			msg.append("extInfo: ");
			msg.append(obj.extInfo);
			msg.append("\n");
			msg.append("filePath: ");
			msg.append(obj.filePath);
			
			//Intent intent = new Intent(this, ShowFromWXActivity.class);
			//intent.putExtra(Constants.ShowMsgActivity.STitle, wxMsg.title);
			//intent.putExtra(Constants.ShowMsgActivity.SMessage, msg.toString());
			//intent.putExtra(Constants.ShowMsgActivity.BAThumbData, wxMsg.thumbData);
			//startActivity(intent);
			finish();
			break;
		default:
			break;
		}
	}

	// ������Ӧ�÷��͵�΢�ŵ�����������Ӧ�������ص����÷���
	@Override
	public void onResp(BaseResp resp) {		
		Log.e("WXEntryActivity", "errCode__"+resp.errCode);
		
		String login_param = ThirdPartyLogin.Instantce.getLoginParam();
		if(resp.errCode== BaseResp.ErrCode.ERR_OK)
		{
			SendAuth.Resp re= ((SendAuth.Resp)resp);
			String token = re.code;
			Log.e("WXEntryActivity", "token__"+token);		
			ThirdPartyLogin.sendToUnity(true, token,login_param,resp.errCode);
		}
		else	
		{		
			ThirdPartyLogin.sendToUnity(false, "",login_param,resp.errCode);
		}		
		
		finish();
	}	
}
