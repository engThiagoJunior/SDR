"""Plota o sinal modulante m(t) esperado na saída do filtro passa-baixa."""
import matplotlib.pyplot as plt
import numpy as np

# Vetor de tempo
t = np.linspace(0, 2, 1000)

# Sinal modulante
m = 3 * np.cos(2 * np.pi * t) + 2 * np.cos(4 * np.pi * t + np.pi / 6)

# Plot
plt.plot(t, m)
plt.xlabel("t (s)")
plt.ylabel("m(t)")
plt.title("m(t) = 3cos(2πt) + 2cos(4πt + π/6)")
plt.grid(True)
plt.savefig("modulating_signal.png")
plt.show()
