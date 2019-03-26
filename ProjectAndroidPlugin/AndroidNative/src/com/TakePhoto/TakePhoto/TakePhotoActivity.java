package com.TakePhoto.TakePhoto;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Bundle;
import android.os.Parcelable;
import android.provider.ContactsContract.Directory;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.util.Base64;
import android.util.Log;
import android.graphics.BitmapFactory;

public class TakePhotoActivity extends Activity {

	// -------------------------------------------------------------------------
	private static final String IMAGE_UNSPECIFIED = "image/*";
	Uri mImageUri;
	public int mPhotoWidth = 150;
	public int mPhotoHeight = 150;
	public String mPhotoName = "";
	public String mPhotoFinalPath="";
	boolean mAlreadyTakePhoto = false;

	// -------------------------------------------------------------------------
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		Log.e("TakePhotoActivity", "onCreate");
		
		mPhotoWidth = this.getIntent().getIntExtra("PhotoWidth", 150);
		mPhotoHeight = this.getIntent().getIntExtra("PhotoHeight", 150);
		mPhotoName = this.getIntent().getStringExtra("PhotoName");
		mPhotoFinalPath = this.getIntent().getStringExtra("PhotoFinalPath");
		String take_phototype = this.getIntent()
				.getStringExtra("TakePhotoType");

		getSavedInstanceState(savedInstanceState);

		if (!this.mAlreadyTakePhoto) {
			File photo_file = new File(
					Environment.getExternalStorageDirectory(), mPhotoName);
			if (photo_file.exists()) {
				photo_file.delete();			
			}								
			
			if (take_phototype.equals(TakePhoto._ERESULT.getPicFromPicture
					.toString())) {
				this.mAlreadyTakePhoto = true;
				mImageUri = Uri.fromFile(photo_file);
				startImagePick();
			} else if (take_phototype
					.equals(TakePhoto._ERESULT.getPicFromCamera.toString())) {
				this.mAlreadyTakePhoto = true;
				if(Build.VERSION.SDK_INT >= 24)
				{				
					mImageUri = FileProvider.getUriForFile(this,this.getApplicationContext().getPackageName() + ".provider", photo_file);  
				}
				else
				{
					mImageUri = Uri.fromFile(photo_file);	
				}
				startActionCamera();
			}
		}
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onStart() {
		super.onStart();
		Log.e("TakePhotoActivity", "onStart");
		checkTakePhoto();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onRestart() {
		super.onRestart();
		Log.e("TakePhotoActivity", "onRestart");
		checkTakePhoto();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onResume() {
		super.onResume();
		Log.e("TakePhotoActivity", "onResume");
		checkTakePhoto();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onPause() {
		super.onPause();
		Log.e("TakePhotoActivity", "onPause");
		checkTakePhoto();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onStop() {
		super.onStop();
		Log.e("TakePhotoActivity", "onStop");
		checkTakePhoto();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onDestroy() {
		super.onDestroy();

		this.mAlreadyTakePhoto = false;
		Log.e("TakePhotoActivity", "onDestroy");
		checkTakePhoto();
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onSaveInstanceState(Bundle outState) {
		Log.e("TakePhotoActivity", "onSaveInstanceState");
		checkTakePhoto();
		outState.putBoolean("AlreadyTakePhoto", this.mAlreadyTakePhoto);
		outState.putParcelable("ImageUri", this.mImageUri);
		outState.putString("PhotoName", mPhotoName);
		outState.putString("PhotoFinalPath", mPhotoFinalPath);
		outState.putInt("PhotoWidth", mPhotoWidth);
		outState.putInt("PhotoHeight", mPhotoHeight);
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		Log.e("TakePhotoActivity", "onRestoreInstanceState");
		checkTakePhoto();

		getSavedInstanceState(savedInstanceState);

		super.onRestoreInstanceState(savedInstanceState);
	}

	// -------------------------------------------------------------------------
	private void getSavedInstanceState(Bundle savedInstanceState) {
		if (savedInstanceState != null) {
			this.mImageUri = savedInstanceState.getParcelable("ImageUri");
			this.mAlreadyTakePhoto = savedInstanceState
					.getBoolean("AlreadyTakePhoto");
			this.mPhotoWidth = savedInstanceState.getInt("PhotoWidth");
			this.mPhotoHeight = savedInstanceState.getInt("PhotoHeight");
			this.mPhotoName = savedInstanceState.getString("PhotoName");
			this.mPhotoFinalPath = savedInstanceState.getString("PhotoFinalPath");

			if (TakePhoto.mTakePhoto == null) {
				TakePhoto.Instantce(mPhotoWidth,
						mPhotoHeight,
						mPhotoName,
						mPhotoFinalPath);
			}
		}
	}

	// -------------------------------------------------------------------------
	private void checkTakePhoto() {
		if (TakePhoto.mTakePhoto == null) {
			Log.e("TakePhotoActivity", "TakePhoto::mTakePhoto::NULL");
		} else {
			Log.e("TakePhotoActivity", "TakePhoto::mTakePhoto::NotNULL");
		}
	}

	// -------------------------------------------------------------------------
	private void startImagePick() {
		Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);		
		this.startActivityForResult(intent,
				TakePhoto._ERESULT.getPicFromPicture.ordinal());
	}

	// -------------------------------------------------------------------------
	private void startActionCamera() {
		Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		intent.putExtra(MediaStore.EXTRA_OUTPUT, mImageUri);
		this.startActivityForResult(intent,
				TakePhoto._ERESULT.getPicFromCamera.ordinal());
	}

	// -------------------------------------------------------------------------
	/**
	 * �ü�
	 * 
	 * @param uri
	 */
	private void __PictureScaleHandle(Uri uri, Boolean is_camera) {
		Intent intent = new Intent("com.android.camera.action.CROP");
		if (Build.VERSION.SDK_INT >= 24) {
			intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);            
        }		       
		intent.setDataAndType(uri, IMAGE_UNSPECIFIED);	
		intent.putExtra("crop", "true");
		// aspectX aspectY �ǿ�ߵı���
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		// outputX outputY �ǲü�ͼƬ���
		intent.putExtra("outputX", mPhotoWidth);
		intent.putExtra("outputY", mPhotoHeight);
		intent.putExtra(MediaStore.EXTRA_OUTPUT, mImageUri);
		intent.putExtra("return-data", false);
		TakePhoto._ERESULT request_code = TakePhoto._ERESULT.getPicFromCameraSuccess;
		if (is_camera == false) {			
			request_code = TakePhoto._ERESULT.getPicFromPictureSuccess;
		}
		Log.d("TakePhotoActivity","__PictureScaleHandle");
		this.startActivityForResult(intent, request_code.ordinal());
	}

	// -------------------------------------------------------------------------
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		Log.e("TakePhotoActivity", "onConfigurationChanged");
		// �����Ļ�ķ�����������
		if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
			// ��ǰΪ������ �ڴ˴���Ӷ���Ĵ������
			Log.e("TakePhotoActivity", "onConfigurationChanged::����");
		} else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
			// ��ǰΪ������ �ڴ˴���Ӷ���Ĵ������
			Log.e("TakePhotoActivity", "onConfigurationChanged��������");
		}

		// ���ʵ����̵�״̬���Ƴ����ߺ���
		if (newConfig.hardKeyboardHidden == Configuration.HARDKEYBOARDHIDDEN_NO) {
			// ʵ����̴����Ƴ�״̬���ڴ˴���Ӷ���Ĵ������
		} else if (newConfig.hardKeyboardHidden == Configuration.HARDKEYBOARDHIDDEN_YES) {
			// ʵ����̴��ں���״̬���ڴ˴���Ӷ���Ĵ������
		}
	}

	// -------------------------------------------------------------------------
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.d("TakePhotoActivity", "onActivityResult::resultCode:: "
				+ resultCode + "  requestCode::" + requestCode);
		// ȡ���ڱ�
		Boolean bIsPhotoHandle = false;
		
		if(resultCode == 0)
		{
			Log.e("TakePhotoActivity", "getPicFailed");
			TakePhoto.sendToUnity(false,
					TakePhoto._ERESULT.getPicFailed.toString());
			finish();
			return;
		}

		// ��������ͼƬ
		if (requestCode == TakePhoto._ERESULT.getPicFromCamera.ordinal()) {
			__PictureScaleHandle(mImageUri, true);
		}
		else
		{
			// �������ͼƬ
			if (requestCode == TakePhoto._ERESULT.getPicFromPicture.ordinal()) {
				if (null == data) {
					bIsPhotoHandle = true;
				} else {					
					__PictureScaleHandle(data.getData(), false);
				}		
			}	
		}		

		if (bIsPhotoHandle) {
			Log.e("TakePhotoActivity", "getPicFailed");
			TakePhoto.sendToUnity(false,
					TakePhoto._ERESULT.getPicFailed.toString());
			finish();
			return;
		}

		// ����ͷ��ͼƬ
		if (requestCode == TakePhoto._ERESULT.getPicFromCameraSuccess.ordinal()) {
			Log.e("TakePhotoActivity", "getPicFromCameraSuccess");
			_decodeUriAsBitmap(this.mImageUri);
			
			finish();
		} else if (requestCode == TakePhoto._ERESULT.getPicFromPictureSuccess
				.ordinal()) {
			Log.e("TakePhotoActivity", "getPicFromPictureSuccess");
			
			_decodeUriAsBitmap(this.mImageUri);

//			Bundle extras = data.getExtras();
//			if (extras != null) {
//				Bitmap photo = extras.getParcelable("data");
//				_saveBitMapToFinalPath(photo);
//			}
			
			finish();
		}
		// }

		super.onActivityResult(requestCode, resultCode, data);
	}

	// -------------------------------------------------------------------------
	private void _decodeUriAsBitmap(Uri uri) {

		// Bitmap bitmap = null;
		
		Bitmap bitmap = null;

		try {
			Log.e("TakePhotoActivity", "_decodeUriAsBitmap");		
			bitmap = BitmapFactory.decodeStream(getContentResolver().openInputStream(uri));
		} catch (Exception e) {
			e.printStackTrace();
			return;
		}
		
		_saveBitMapToFinalPath(bitmap);
//		InputStream in = null;
//		byte[] data = null;
//		// ��ȡͼƬ�ֽ�����
//		try {
//			in = new FileInputStream(uri.getPath());
//			data = new byte[in.available()];
//			in.read(data);
//			in.close();
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//
//		Log.e("TakePhotoActivity", "imagedata����Length::" + data.length);
//		// ���ֽ�����Base64����
//		String image_str = Base64Coder.encodeLines(data);
//		TakePhoto.sendToUnity(true, image_str);
//		Log.e("TakePhotoActivity", "image_str:: " + image_str);
		/*
		 * try { BitmapFactory.Options options = new BitmapFactory.Options();
		 * options.inPreferredConfig = Config.RGB_565; bitmap =
		 * BitmapFactory.decodeStream(getContentResolver()
		 * .openInputStream(uri), null, options); } catch (Exception e) {
		 * e.printStackTrace(); return; }
		 */

		// _picToString(bitmap);
	}
	
	// -------------------------------------------------------------------------
	void _saveBitMapToFinalPath(Bitmap bit_map)
	{	
		FileOutputStream file_out_stream = null;
		 
		try {										
			  File destDir = new File(mPhotoFinalPath);
			  if (!destDir.exists())
			  { 				  
				  destDir.mkdirs();
			  }			 
 
			  file_out_stream = new FileOutputStream(mPhotoFinalPath + "/" + mPhotoName) ;
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		
		//��Bitmap����д�뱾��·���У�Unity��ȥ��ͬ��·������ȡ����ļ�
		bit_map.compress(Bitmap.CompressFormat.JPEG, 100, file_out_stream);
		try {
			file_out_stream.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			file_out_stream.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
				
		TakePhoto.sendToUnity(true, "0");		
	}

	// -------------------------------------------------------------------------
	private void _picToString(Bitmap photo) {
		String icon = "";
		try {
			// File file = new File(photo.);

			// ����һ���ֽ����������,���Ĵ�СΪsize
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			// ����λͼ��ѹ����ʽ������Ϊ100%���������ֽ������������
			photo.compress(Bitmap.CompressFormat.PNG, 100, baos);
			// ���ֽ����������ת��Ϊ�ֽ�����byte[]
			byte[] imagedata = baos.toByteArray();
			Log.e("TakePhotoActivity", "imagedata����Length::" + imagedata.length);
			icon = Base64.encodeToString(imagedata, Base64.DEFAULT);
		} catch (Exception e) {
			e.printStackTrace();
			return;
		}

		TakePhoto.sendToUnity(true, icon);
		Log.e("TakePhotoActivity", "icon:: " + icon);
	}

	// -------------------------------------------------------------------------
	private void getPicStringThread(final Uri image_uri) {
		(new Thread(new Runnable() {
			public void run() {
				_decodeUriAsBitmap(image_uri);
			}
		})).start();
	}

	// String icon = "";
	// try {
	// // ����һ���ֽ����������,���Ĵ�СΪsize
	// ByteArrayOutputStream baos = new ByteArrayOutputStream();
	// // ����λͼ��ѹ����ʽ������Ϊ100%���������ֽ������������
	// bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
	// baos.flush();
	// baos.close();
	//
	// // ���ֽ����������ת��Ϊ�ֽ�����byte[]
	// byte[] imagedata = baos.toByteArray();
	// Log.e("TakePhotoActivity", "imagedata����Length::" + imagedata.length);
	// icon = Base64.encodeToString(imagedata, Base64.DEFAULT);
	// // Log.e("TakePhotoActivity", "icon:: " + icon);
	// } catch (Exception e) {
	// e.printStackTrace();
	// return;
	// }
	//
	// TakePhoto.sendToUnity(true, icon);

	// ----------------------------------------------------------------------
	/**
	 * ����ͼƬ
	 * 
	 * @param photo
	 * @throws IOException
	 */
	@SuppressLint("SdCardPath")
	private void __SavePicture(Bitmap photo) throws IOException {

		FileOutputStream fOut = null;
		try {
			String strPackgeName = getApplicationInfo().packageName;
			Log.e("TakePhotoActivity", "getPicSuccess::strPackgeName:: "
					+ strPackgeName);
			String path = "/mnt/sdcard/Android/data/" + strPackgeName
					+ "/files";
			Log.e("TakePhotoActivity", "getPicSuccess::path:: " + path);
			File destDir = new File(path);
			if (!destDir.exists()) {
				destDir.mkdirs();
			}

			fOut = new FileOutputStream(path + "/" + mPhotoName);
		} catch (FileNotFoundException e) {
			Log.e("TakePhotoActivity::Error::", e.getMessage());
			e.printStackTrace();
		}

		// ��Bitmap����д�뱾��·���У�Unity��ȥ��ͬ��·������ȡ����ļ�
		photo.compress(Bitmap.CompressFormat.PNG, 100, fOut);

		try {
			fOut.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}

		try {
			fOut.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
