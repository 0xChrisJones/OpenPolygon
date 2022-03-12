import '../styles/globals.css';
import type { AppProps } from 'next/app';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { OpenPolygonProvider } from '../context/OpenPolygonContext';

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <OpenPolygonProvider>
        <Navbar />
        <main>
          <Component {...pageProps} />
        </main>
        <Footer />
      </OpenPolygonProvider>
    </>
  );
}

export default MyApp;
