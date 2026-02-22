import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './firebase';
import Layout from './components/Layout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Doctors from './pages/Doctors';
import DoctorDetail from './pages/DoctorDetail';
import Appointments from './pages/Appointments';
import Users from './pages/Users';
import Reviews from './pages/Reviews';
import Settings from './pages/Settings';

function App() {
  const [user, setUser] = useState(null);
  const [adminData, setAdminData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        try {
          const adminDoc = await getDoc(doc(db, 'admins', firebaseUser.uid));
          if (adminDoc.exists()) {
            setUser(firebaseUser);
            setAdminData({ id: adminDoc.id, ...adminDoc.data() });
          } else {
            setUser(null);
            setAdminData(null);
          }
        } catch (err) {
          console.error('Error checking admin status:', err);
          setUser(null);
          setAdminData(null);
        }
      } else {
        setUser(null);
        setAdminData(null);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  if (loading) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', background: '#f0f2f5' }}>
        <div className="spinner" />
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        <Route path="/login" element={user ? <Navigate to="/" /> : <Login />} />
        <Route
          path="/*"
          element={
            user ? (
              <Layout adminData={adminData}>
                <Routes>
                  <Route path="/" element={<Dashboard />} />
                  <Route path="/doctors" element={<Doctors />} />
                  <Route path="/doctors/:id" element={<DoctorDetail />} />
                  <Route path="/appointments" element={<Appointments />} />
                  <Route path="/users" element={<Users />} />
                  <Route path="/reviews" element={<Reviews />} />
                  <Route path="/settings" element={<Settings adminData={adminData} />} />
                  <Route path="*" element={<Navigate to="/" />} />
                </Routes>
              </Layout>
            ) : (
              <Navigate to="/login" />
            )
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
