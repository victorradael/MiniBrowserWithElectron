import { useState, useEffect } from 'react'
import { ChevronDown, ChevronUp, ChevronRight, ChevronLeft } from 'lucide-react'

export default function ScrollIndicator({ containerRef, direction = 'vertical' }) {
    const [showStart, setShowStart] = useState(false)
    const [showEnd, setShowEnd] = useState(false)

    useEffect(() => {
        const container = containerRef.current
        if (!container) return

        const checkScroll = () => {
            if (direction === 'vertical') {
                const { scrollTop, scrollHeight, clientHeight } = container
                setShowStart(scrollTop > 5)
                setShowEnd(scrollTop + clientHeight < scrollHeight - 5)
            } else {
                const { scrollLeft, scrollWidth, clientWidth } = container
                setShowStart(scrollLeft > 5)
                setShowEnd(scrollLeft + clientWidth < scrollWidth - 5)
            }
        }

        // Initial check
        checkScroll()

        // Check on scroll
        container.addEventListener('scroll', checkScroll)

        // Check on resize (of window or content)
        const resizeObserver = new ResizeObserver(checkScroll)
        resizeObserver.observe(container)

        // Also watch for child changes if possible, or just rely on ResizeObserver

        return () => {
            container.removeEventListener('scroll', checkScroll)
            resizeObserver.disconnect()
        }
    }, [containerRef, direction])

    if (direction === 'vertical') {
        return (
            <>
                {showStart && (
                    <div className="absolute top-2 left-1/2 -translate-x-1/2 z-20 pointer-events-none animate-bounce bg-gray-900/40 p-1 rounded-full backdrop-blur-sm border border-gray-700/50 text-blue-500/70">
                        <ChevronUp size={20} />
                    </div>
                )}
                {showEnd && (
                    <div className="absolute bottom-2 left-1/2 -translate-x-1/2 z-20 pointer-events-none animate-bounce bg-gray-900/40 p-1 rounded-full backdrop-blur-sm border border-gray-700/50 text-blue-500/70">
                        <ChevronDown size={20} />
                    </div>
                )}
            </>
        )
    }

    return (
        <>
            {showStart && (
                <div className="absolute left-2 top-1/2 -translate-y-1/2 z-20 pointer-events-none animate-pulse bg-gray-900/40 p-1 rounded-full backdrop-blur-sm border border-gray-700/50 text-blue-500/70">
                    <ChevronLeft size={20} />
                </div>
            )}
            {showEnd && (
                <div className="absolute right-2 top-1/2 -translate-y-1/2 z-20 pointer-events-none animate-pulse bg-gray-900/40 p-1 rounded-full backdrop-blur-sm border border-gray-700/50 text-blue-500/70">
                    <ChevronRight size={20} />
                </div>
            )}
        </>
    )
}
