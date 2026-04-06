import React from 'react';
import { Upload, X, Image } from 'lucide-react';

const CLOUD_NAME = 'dz0ug5gey';
const UPLOAD_PRESET = 'doctor_clinic_preset';

export function CloudinaryUploadSingle({ label, value, onChange, folder = 'doctors' }) {
  const openWidget = () => {
    window.cloudinary.openUploadWidget(
      {
        cloudName: CLOUD_NAME,
        uploadPreset: UPLOAD_PRESET,
        folder: folder,
        sources: ['local', 'url', 'camera'],
        multiple: false,
        maxFiles: 1,
        cropping: false,
        resourceType: 'image',
        clientAllowedFormats: ['jpg', 'jpeg', 'png', 'webp'],
        maxFileSize: 5000000,
        styles: {
          palette: {
            window: '#ffffff',
            windowBorder: '#90a0b3',
            tabIcon: '#667eea',
            menuIcons: '#5a616a',
            textDark: '#000000',
            textLight: '#ffffff',
            link: '#667eea',
            action: '#667eea',
            inactiveTabIcon: '#0e2f5a',
            error: '#f44235',
            inProgress: '#667eea',
            complete: '#20b832',
            sourceBg: '#e4ebf1',
          },
        },
      },
      (error, result) => {
        if (!error && result && result.event === 'success') {
          onChange(result.info.secure_url);
        }
      }
    );
  };

  return (
    <div className="form-group">
      <label>{label}</label>
      {value ? (
        <div style={{ position: 'relative', display: 'inline-block' }}>
          <img
            src={value}
            alt={label}
            style={{
              width: '100%',
              maxHeight: 150,
              objectFit: 'cover',
              borderRadius: 8,
              border: '1px solid #e0e0e0',
            }}
          />
          <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
            <button
              type="button"
              className="btn btn-sm btn-outline"
              onClick={openWidget}
              style={{ flex: 1 }}
            >
              <Upload size={13} /> Change
            </button>
            <button
              type="button"
              className="btn btn-sm btn-outline"
              onClick={() => onChange('')}
              style={{ color: '#f44336', borderColor: '#f44336' }}
            >
              <X size={13} /> Remove
            </button>
          </div>
        </div>
      ) : (
        <div
          onClick={openWidget}
          style={{
            border: '2px dashed #d0d5dd',
            borderRadius: 8,
            padding: '24px 16px',
            textAlign: 'center',
            cursor: 'pointer',
            background: '#fafafa',
            transition: 'all 0.2s',
          }}
          onMouseEnter={e => { e.currentTarget.style.borderColor = '#667eea'; e.currentTarget.style.background = '#f0f2ff'; }}
          onMouseLeave={e => { e.currentTarget.style.borderColor = '#d0d5dd'; e.currentTarget.style.background = '#fafafa'; }}
        >
          <Upload size={24} color="#667eea" style={{ marginBottom: 6 }} />
          <p style={{ margin: 0, fontSize: 13, color: '#667eea', fontWeight: 500 }}>Click to upload</p>
          <p style={{ margin: '4px 0 0', fontSize: 11, color: '#8b8b8b' }}>JPG, PNG, WEBP (max 5MB)</p>
        </div>
      )}
    </div>
  );
}

export function CloudinaryUploadMultiple({ label, values = [], onChange, folder = 'doctors/degrees' }) {
  const openWidget = () => {
    window.cloudinary.openUploadWidget(
      {
        cloudName: CLOUD_NAME,
        uploadPreset: UPLOAD_PRESET,
        folder: folder,
        sources: ['local', 'url', 'camera'],
        multiple: true,
        maxFiles: 10,
        cropping: false,
        resourceType: 'image',
        clientAllowedFormats: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        maxFileSize: 10000000,
        styles: {
          palette: {
            window: '#ffffff',
            windowBorder: '#90a0b3',
            tabIcon: '#667eea',
            menuIcons: '#5a616a',
            textDark: '#000000',
            textLight: '#ffffff',
            link: '#667eea',
            action: '#667eea',
            inactiveTabIcon: '#0e2f5a',
            error: '#f44235',
            inProgress: '#667eea',
            complete: '#20b832',
            sourceBg: '#e4ebf1',
          },
        },
      },
      (error, result) => {
        if (!error && result && result.event === 'success') {
          onChange([...values, result.info.secure_url]);
        }
      }
    );
  };

  const removeImage = (index) => {
    onChange(values.filter((_, i) => i !== index));
  };

  return (
    <div className="form-group">
      <label>{label}</label>
      {values.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginBottom: 8 }}>
          {values.map((url, i) => (
            <div
              key={i}
              style={{
                position: 'relative',
                width: 90,
                height: 90,
                borderRadius: 8,
                overflow: 'hidden',
                border: '1px solid #e0e0e0',
              }}
            >
              <img src={url} alt={`${label} ${i + 1}`} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              <button
                type="button"
                onClick={() => removeImage(i)}
                style={{
                  position: 'absolute',
                  top: 4,
                  right: 4,
                  background: 'rgba(244,67,54,0.9)',
                  color: 'white',
                  border: 'none',
                  borderRadius: '50%',
                  width: 20,
                  height: 20,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  cursor: 'pointer',
                  padding: 0,
                }}
              >
                <X size={12} />
              </button>
            </div>
          ))}
        </div>
      )}
      <div
        onClick={openWidget}
        style={{
          border: '2px dashed #d0d5dd',
          borderRadius: 8,
          padding: '16px 12px',
          textAlign: 'center',
          cursor: 'pointer',
          background: '#fafafa',
          transition: 'all 0.2s',
        }}
        onMouseEnter={e => { e.currentTarget.style.borderColor = '#667eea'; e.currentTarget.style.background = '#f0f2ff'; }}
        onMouseLeave={e => { e.currentTarget.style.borderColor = '#d0d5dd'; e.currentTarget.style.background = '#fafafa'; }}
      >
        <Image size={20} color="#667eea" style={{ marginBottom: 4 }} />
        <p style={{ margin: 0, fontSize: 12, color: '#667eea', fontWeight: 500 }}>
          {values.length > 0 ? 'Add more images' : 'Click to upload images'}
        </p>
        <p style={{ margin: '2px 0 0', fontSize: 11, color: '#8b8b8b' }}>JPG, PNG, WEBP, PDF (max 10MB each)</p>
      </div>
    </div>
  );
}
