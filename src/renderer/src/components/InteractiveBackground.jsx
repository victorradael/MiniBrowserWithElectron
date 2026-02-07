import React, { useEffect, useRef } from 'react';

const InteractiveBackground = () => {
    const canvasRef = useRef(null);

    useEffect(() => {
        const canvas = canvasRef.current;
        const ctx = canvas.getContext('2d');
        let animationFrameId;

        let width = window.innerWidth;
        let height = window.innerHeight;

        const particles = [];
        const colors = ['#3b82f6', '#60a5fa', '#1d4ed8', '#93c5fd'];
        const mouse = { x: null, y: null, radius: 150 };
        let time = 0;

        class Particle {
            constructor() {
                this.x = Math.random() * width;
                this.y = Math.random() * height;
                this.size = Math.random() * 1.5 + 0.5;
                // Store relative position (0.0 to 1.0)
                this.relX = this.x / width;
                this.relY = this.y / height;
                this.baseX = this.x;
                this.baseY = this.y;
                this.density = (Math.random() * 20) + 1;
                this.color = colors[Math.floor(Math.random() * colors.length)];
                // Individual wave parameters - Slowed down
                this.angle = Math.random() * Math.PI * 2;
                this.velocity = Math.random() * 0.005 + 0.002;
                this.amplitude = Math.random() * 15 + 5;
            }

            draw() {
                ctx.fillStyle = this.color;

                // Add subtle glow
                ctx.shadowBlur = 4;
                ctx.shadowColor = this.color;

                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.closePath();
                ctx.fill();

                ctx.shadowBlur = 0;
            }

            update() {
                // Wave rotation/oscillation
                this.angle += this.velocity;
                const waveX = Math.cos(this.angle) * this.amplitude;
                const waveY = Math.sin(this.angle) * this.amplitude;

                const targetX = this.baseX + waveX;
                const targetY = this.baseY + waveY;

                let dx = mouse.x - this.x;
                let dy = mouse.y - this.y;
                let distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < mouse.radius) {
                    let forceDirectionX = dx / distance;
                    let forceDirectionY = dy / distance;
                    let maxDistance = mouse.radius;
                    let force = (maxDistance - distance) / maxDistance;
                    let directionX = forceDirectionX * force * this.density;
                    let directionY = forceDirectionY * force * this.density;

                    this.x -= directionX;
                    this.y -= directionY;
                } else {
                    // Smooth return to target (which is base + wave)
                    const dxT = this.x - targetX;
                    const dyT = this.y - targetY;
                    this.x -= dxT / 20;
                    this.y -= dyT / 20;
                }
            }
        }

        const resize = () => {
            width = window.innerWidth;
            height = window.innerHeight;
            canvas.width = width;
            canvas.height = height;

            // Reposition particles based on relative coordinates
            particles.forEach(p => {
                p.x = p.relX * width;
                p.y = p.relY * height;
                p.baseX = p.x;
                p.baseY = p.y;
            });

            // Dynamic Density: 1 particle per ~25000 pixels
            // 1920x1080 = ~2M pixels -> ~80 particles
            // 1366x768 = ~1M pixels -> ~40 particles
            const area = width * height;
            const targetCount = Math.floor(area / 25000);

            if (particles.length < targetCount) {
                // Add more particles
                const toAdd = targetCount - particles.length;
                for (let i = 0; i < toAdd; i++) {
                    particles.push(new Particle());
                }
            } else if (particles.length > targetCount) {
                // Remove excess particles
                particles.splice(targetCount);
            }
        };

        window.addEventListener('resize', resize);
        window.addEventListener('mousemove', (e) => {
            mouse.x = e.x;
            mouse.y = e.y;
        });

        // Initial setup
        resize();

        const connect = () => {
            for (let a = 0; a < particles.length; a++) {
                for (let b = a; b < particles.length; b++) {
                    let dx = particles[a].x - particles[b].x;
                    let dy = particles[a].y - particles[b].y;
                    let distance = Math.sqrt(dx * dx + dy * dy);

                    if (distance < 130) {
                        const opacityValue = 1 - (distance / 130);
                        ctx.strokeStyle = `rgba(59, 130, 246, ${opacityValue * 0.15})`;
                        ctx.lineWidth = 0.5;
                        ctx.beginPath();
                        ctx.moveTo(particles[a].x, particles[a].y);
                        ctx.lineTo(particles[b].x, particles[b].y);
                        ctx.stroke();
                    }
                }
            }
        }

        const animate = () => {
            ctx.clearRect(0, 0, width, height);
            time += 0.005;
            for (let i = 0; i < particles.length; i++) {
                particles[i].draw();
                particles[i].update();
            }
            connect();
            animationFrameId = requestAnimationFrame(animate);
        };

        animate();

        return () => {
            window.removeEventListener('resize', resize);
            cancelAnimationFrame(animationFrameId);
        };
    }, []);

    return (
        <canvas
            ref={canvasRef}
            className="fixed inset-0 pointer-events-none z-0"
            style={{ opacity: 0.6 }}
        />
    );
};

export default InteractiveBackground;
