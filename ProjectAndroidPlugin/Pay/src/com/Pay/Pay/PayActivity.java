package com.Pay.Pay;

import com.pingplusplus.android.Pingpp;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

public class PayActivity extends Activity {
	boolean mAlreadyPay = false;

	// -------------------------------------------------------------------------
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.e("PayActivity", "onCreate");		

		_getSavedInstanceState(savedInstanceState);

		if (!mAlreadyPay) {
			String pay_data = this.getIntent().getStringExtra("Pay");
			Log.e("PayActivity", "pay::" + pay_data);
			Pingpp.createPayment(PayActivity.this, pay_data);
		}
	}

	// -------------------------------------------------------------------------
	/**
	 * onActivityResult ���֧����������֧���ɹ������������յ�ping++ ���������͵��첽֪ͨ�� ����֧���ɹ������첽֪ͨΪ׼
	 */
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		//֧��ҳ�淵�ش���
	    if (requestCode == Pingpp.REQUEST_CODE_PAYMENT) {
	        if (resultCode == Activity.RESULT_OK) {
	            String result = data.getExtras().getString("pay_result");
	            /* ������ֵ
	             * "success" - ֧���ɹ�
	             * "fail"    - ֧��ʧ��
	             * "cancel"  - ȡ��֧��
	             * "invalid" - ֧�����δ��װ��һ����΢�ſͻ���δ��װ�������
	             * "unknown" - app�����쳣��ɱ��(һ���ǵ��ڴ�״̬��,app���̱�ɱ��)
	             */	            
	            String errorMsg = data.getExtras().getString("error_msg"); // ������Ϣ
	            String extraMsg = data.getExtras().getString("extra_msg"); // ������Ϣ
	            
	            boolean is_success = false;
	            String total_result = result;
	            
	            if( result.equalsIgnoreCase("success")){
	            	is_success = true;
	            }else if(result.equalsIgnoreCase("fail")){
	            	total_result = total_result +";err_msg=" + errorMsg +";detail=" + extraMsg;
	            }	
	            
	            Log.e("PayActivity", "PayResult:" + total_result);
	            Pay.sendToUnity(is_success,total_result,total_result,10000);
	            
	            this.mAlreadyPay = true;
	        }
	    }
	    
	    finish();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onSaveInstanceState(Bundle outState) {
		Log.e("PayActivity", "onSaveInstanceState");

		outState.putBoolean("AlreadyPay", this.mAlreadyPay);
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		Log.e("PayActivity", "onRestoreInstanceState");

		_getSavedInstanceState(savedInstanceState);
	}

	// -------------------------------------------------------------------------
	void _getSavedInstanceState(Bundle savedInstanceState) {
		if (savedInstanceState != null) {
			this.mAlreadyPay = savedInstanceState.getBoolean("AlreadyPay");
		}
	}
}
