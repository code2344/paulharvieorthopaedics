// Contact Form Handler
document.addEventListener('DOMContentLoaded', function() {
    const syncTreatmentHeights = () => {
        const treatmentCards = document.querySelectorAll('.treatment-card');
        const shouldStack = window.matchMedia('(max-width: 1024px)').matches;

        treatmentCards.forEach(card => {
            const imageWrap = card.querySelector('.treatment-image');
            const content = card.querySelector('.treatment-content');

            if (!imageWrap || !content) {
                return;
            }

            imageWrap.style.height = 'auto';

            if (!shouldStack) {
                const contentHeight = content.scrollHeight;
                imageWrap.style.height = `${contentHeight}px`;
            }
        });
    };

    const bindTreatmentObservers = () => {
        const treatmentCards = document.querySelectorAll('.treatment-card');

        treatmentCards.forEach(card => {
            const image = card.querySelector('.treatment-image img');
            const content = card.querySelector('.treatment-content');

            if (image && !image.complete) {
                image.addEventListener('load', syncTreatmentHeights);
            }

            if (content && 'ResizeObserver' in window) {
                const observer = new ResizeObserver(() => {
                    syncTreatmentHeights();
                });
                observer.observe(content);
            }
        });
    };

    const contactForm = document.querySelector('.contact-form');
    
    if (contactForm) {
        contactForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            // Get form values
            const name = this.querySelector('input[placeholder="Your Name"]').value;
            const email = this.querySelector('input[placeholder="Your Email"]').value;
            const phone = this.querySelector('input[placeholder="Your Phone"]').value;
            const message = this.querySelector('textarea').value;
            
            // Validate form
            if (!name || !email || !message) {
                alert('Please fill in all required fields (Name, Email, and Message)');
                return;
            }
            
            // Validate email
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert('Please enter a valid email address');
                return;
            }
            
            // Create form data
            const formData = new FormData(this);
            
            try {
                // Submit to Formspree
                const response = await fetch('https://formspree.io/f/xvgezkqj', {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'Accept': 'application/json'
                    }
                });
                
                if (response.ok) {
                    // Success message
                    const button = this.querySelector('button[type="submit"]');
                    const originalText = button.textContent;
                    
                    button.textContent = '✓ Message Sent!';
                    button.style.backgroundColor = '#28a745';
                    
                    // Reset form
                    this.reset();
                    
                    // Reset button after 3 seconds
                    setTimeout(() => {
                        button.textContent = originalText;
                        button.style.backgroundColor = '';
                    }, 3000);
                } else {
                    alert('There was an error sending your message. Please try again.');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('There was an error sending your message. Please try again or call 03 6214 3060');
            }
        });
    }
    
    // Scroll to section when clicking nav links
    const navLinks = document.querySelectorAll('.nav-menu a');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href.startsWith('#')) {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }
        });
    });
    
    // CTA Button scrolling
    const ctaButtons = document.querySelectorAll('.cta-button');
    ctaButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href && href.startsWith('#')) {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }
        });
    });

    syncTreatmentHeights();
    bindTreatmentObservers();
    window.addEventListener('resize', syncTreatmentHeights);
    window.addEventListener('load', syncTreatmentHeights);
});

// Microsoft Clarity Analytics
(function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
    y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
})(window, document, "clarity", "script", "vmm85mx10f");

