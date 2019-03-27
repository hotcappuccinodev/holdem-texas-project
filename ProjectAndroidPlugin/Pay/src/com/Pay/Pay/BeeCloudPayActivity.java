package com.Pay.Pay;

import cn.beecloud.BCPay;
import cn.beecloud.async.BCCallback;
import cn.beecloud.async.BCResult;
import cn.beecloud.entity.BCPayResult;
import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

public class BeeCloudPayActivity extends Activity {
	boolean mAlreadyPay = false;

	BCCallback bcCallback = new BCCallback() {
        @Override
        public void done(final BCResult bcResult) {        	
            final BCPayResult bcPayResult = (BCPayResult)bcResult;           
            String result = bcPayResult.getResult();
            Integer err_code = bcPayResult.getErrCode();
            String msg = "";
            boolean is_success = false;
            if (result.equals(BCPayResult.RESULT_SUCCESS)){
            	msg = "success";
            	is_success = true;
            } 
            else if (result.equals(BCPayResult.RESULT_CANCEL)){
            	msg = "cancel";
            }
            else if (result.equals(BCPayResult.RESULT_FAIL)){
            	msg = "err_msg=" + bcPayResult.getErrMsg() + ";detail=" + bcPayResult.getDetailInfo();         	
            } else if (result.equals(BCPayResult.RESULT_UNKNOWN)) {   
            	msg = "unknown";	// ΢��δ��װ
            } else {
            	msg = "invalid";	// app���̱�ɱ��
            }
            mAlreadyPay = true;
            Pay.sendToUnity(is_success,result.toLowerCase(),msg,err_code);
            finish();
        }
    };
    
	// -------------------------------------------------------------------------
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);			
		_getSavedInstanceState(savedInstanceState);

		if (!mAlreadyPay) {			
			int channel_type = this.getIntent().getIntExtra("ChannelType", 0);				
			String bill_title = this.getIntent().getStringExtra("BillTitle");
			int bill_totalfee = this.getIntent().getIntExtra("BillTotalFee", 1);
			String bill_num = this.getIntent().getStringExtra("BillNum");
			String buy_id = this.getIntent().getStringExtra("BuyId");		
			 switch (channel_type) {
             case 0: //΢��                                  
                 if (BCPay.isWXAppInstalledAndSupported() &&
                         BCPay.isWXPaySupported()) {

                     BCPay.getInstance(BeeCloudPayActivity.this).reqWXPaymentAsync(
                    		 bill_title,               //��������
                    		 bill_totalfee,                           //�������(��)
                    		 bill_num,  //������ˮ��
                             null,            //��չ����(����null)
                             bcCallback);            //֧����ɺ�ص����
                 }
                 break;
             case 1: //֧����֧��                
                 BCPay.getInstance(BeeCloudPayActivity.this).reqAliPaymentAsync(
                		 bill_title,
                		 bill_totalfee,
                         bill_num,
                         null,
                         bcCallback);

                 break;
			 }
		}
	}
	
	// -------------------------------------------------------------------------
	@Override
	protected void onSaveInstanceState(Bundle outState) {
		Log.e("BeeCloudPayActivity", "onSaveInstanceState");

		outState.putBoolean("AlreadyPay", this.mAlreadyPay);
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		Log.e("BeeCloudPayActivity", "onRestoreInstanceState");

		_getSavedInstanceState(savedInstanceState);
	}

	// -------------------------------------------------------------------------
	void _getSavedInstanceState(Bundle savedInstanceState) {
		if (savedInstanceState != null) {
			this.mAlreadyPay = savedInstanceState.getBoolean("AlreadyPay");
		}
	}
}
