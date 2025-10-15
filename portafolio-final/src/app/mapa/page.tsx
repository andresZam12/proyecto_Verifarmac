// src/app/mapa/page.tsx
"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

type Dir = "up" | "right" | "down" | "left";

export default function MapaPage() {
  // Posición del avatar en % dentro del contenedor del mapa
  const [pos, setPos] = useState({ x: 18, y: 72 });
  const [dir, setDir] = useState<Dir>("right");
  const [moving, setMoving] = useState(false);

  // Movimiento con flechas
  useEffect(() => {
    let raf: number | null = null;

    const speed = 0.45; // velocidad en % por frame
    const keys = {
      ArrowUp: false,
      ArrowDown: false,
      ArrowLeft: false,
      ArrowRight: false,
    };

    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key in keys) {
        (keys as any)[e.key] = true;
        setMoving(true);
        if (e.key === "ArrowUp") setDir("up");
        if (e.key === "ArrowDown") setDir("down");
        if (e.key === "ArrowLeft") setDir("left");
        if (e.key === "ArrowRight") setDir("right");
      }
    };

    const onKeyUp = (e: KeyboardEvent) => {
      if (e.key in keys) {
        (keys as any)[e.key] = false;
        if (!Object.values(keys).some(Boolean)) setMoving(false);
      }
    };

    const tick = () => {
      setPos((p) => {
        let { x, y } = p;
        if (keys.ArrowUp) y -= speed;
        if (keys.ArrowDown) y += speed;
        if (keys.ArrowLeft) x -= speed;
        if (keys.ArrowRight) x += speed;

        // límites (0–100%)
        x = Math.max(0, Math.min(100, x));
        y = Math.max(0, Math.min(100, y));
        return { x, y };
      });
      raf = requestAnimationFrame(tick);
    };

    window.addEventListener("keydown", onKeyDown);
    window.addEventListener("keyup", onKeyUp);
    raf = requestAnimationFrame(tick);

    return () => {
      window.removeEventListener("keydown", onKeyDown);
      window.removeEventListener("keyup", onKeyUp);
      if (raf) cancelAnimationFrame(raf);
    };
  }, []);

  return (
    <main className="min-h-screen w-full flex items-center justify-center bg-[#072130]">
      {/* Contenedor del mapa (cuadrado y centrado) */}
      <div className="relative w-[min(92vw,950px)] aspect-square overflow-hidden">
        {/* Fondo del mapa */}
        <div
          className="absolute inset-0 bg-center bg-no-repeat bg-contain"
          style={{ backgroundImage: 'url("/assets/mapa-overworld.jpg")' }}
          aria-hidden
        />

        {/* Botón Volver */}
        <Link
          href="/"
          className="absolute top-4 left-4 z-30 bg-[#2b93ff] text-yellow-300 border-8 border-black rounded-md shadow-[0_10px_0_#000] px-3 py-1 font-[PressStart] text-[12px]"
        >
          VOLVER
        </Link>

        {/* Carteles (ahora con href) */}
        <MapLabel text="Proyectos"       top="10%" left="23%" href="/proyectos" />
        <MapLabel text="Acerca de Mi"    top="13%" left="73%" href="/acerca" />
        <MapLabel text="Opiniones"       top="83%" left="18%" href="/opiniones" />
        <MapLabel text="Línea de tiempo" top="73%" left="76%" href="/timeline" />

        {/* Globito central */}
        <SpeechBubble top="47%" left="49%">
          Explora el mapa para <br /> conocer mi portafolio
        </SpeechBubble>

        {/* Signo de interrogación PNG (abajo derecha, zona “polpixel”) */}
        <div
          className="absolute z-30 animate-bob"
          style={{ bottom: "6%", right: "7%" }}
          title="Ayuda"
          aria-hidden
        >
          <Image
            src="/assets/question.png"  // tu PNG sin fondo
            alt="Ayuda"
            width={40}
            height={56}
            priority
            className="select-none"
            style={{ imageRendering: "pixelated", display: "block" }}
          />
        </div>

        {/* Avatar PNG (idle bob cuando no se mueve) */}
        <div
          className="absolute z-20"
          style={{
            left: `${pos.x}%`,
            top: `${pos.y}%`,
            transform: "translate(-50%, -80%)",
          }}
        >
          <Image
            src="/assets/avatar-parado.png"
            alt="Avatar"
            width={96}
            height={96}
            priority
            className={moving ? "select-none" : "select-none animate-bob"}
            style={{ imageRendering: "pixelated" }}
          />
        </div>
      </div>

      {/* Animaciones CSS locales */}
      <style jsx>{`
        @keyframes bob {
          0% {
            transform: translateY(0);
          }
          50% {
            transform: translateY(-6px);
          }
          100% {
            transform: translateY(0);
          }
        }
        .animate-bob {
          animation: bob 1.4s ease-in-out infinite;
        }
      `}</style>
    </main>
  );
}

/* ---------- Componentes auxiliares ---------- */

function MapLabel({
  text,
  top,
  left,
  href,
}: {
  text: string;
  top: string;
  left: string;
  href?: string;
}) {
  const box = (
    <div className="bg-[#2b2367] text-[#ffd54a] border-8 border-black rounded-md shadow-[0_10px_0_#000] px-4 py-2 font-[PressStart] text-[12px]">
      {text}
    </div>
  );

  return (
    <div
      className="absolute z-20"
      style={{ top, left, transform: "translate(-50%, -50%)" }}
    >
      {href ? (
        <Link href={href} className="block hover:scale-[1.04] transition-transform">
          {box}
        </Link>
      ) : (
        box
      )}
    </div>
  );
}

function SpeechBubble({
  top,
  left,
  children,
}: {
  top: string;
  left: string;
  children: React.ReactNode;
}) {
  return (
    <div
      className="absolute z-10"
      style={{ top, left, transform: "translate(-50%, -50%)" }}
    >
      <div className="bg-white text-black border-8 border-black rounded-md px-4 py-3 shadow-[0_8px_0_#000] font-[PressStart] text-[11px] leading-relaxed text-center">
        {children}
      </div>
      {/* piquito negro */}
      <div
        className="mx-auto"
        style={{
          width: 0,
          height: 0,
          borderLeft: "10px solid transparent",
          borderRight: "10px solid transparent",
          borderTop: "12px solid #000",
          transform: "translateY(-3px)",
        }}
      />
      {/* piquito blanco */}
      <div
        className="mx-auto"
        style={{
          width: 0,
          height: 0,
          borderLeft: "8px solid transparent",
          borderRight: "8px solid transparent",
          borderTop: "10px solid #fff",
          transform: "translateY(-13px)",
        }}
      />
    </div>
  );
}
