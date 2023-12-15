using AcousticAnalysis
using PyFormattedStrings
using PyPlot, PyCall
pplt = pyimport("proplot")
plt = pyimport("matplotlib.pyplot")
pplt.close("all")

# ==============================================================================
# Loading & Saving Data
# ==============================================================================

calibration_factor = 256 * 1e-9

pth1 = load_wav("data/01.wav"; calibration_factor=calibration_factor)
pth2 = load_wav("data/02.wav"; calibration_factor=calibration_factor)
save_h5(pth1, "out/01_new.h5")


# ==============================================================================
# Plotting
# ==============================================================================

bpf1=93.3
bpf2=93.3

plot_spectrogram(pth2; y_max=1000, fname="out/spectrogram.png", t_window=0.5)
plot_narrowband_spectrum(pth1; bpf=bpf1, fname="out/spectrum.png", type=:amplitude, aweighting=true)
plot_propband_spectrum([pth1, pth2]; aweighting=true, fname="out/spectrum_proportional_A.png", label=["1", "2"], alpha=1, lw=1)


# ==============================================================================
# Signal Processing
# ==============================================================================

# Filtering
highpass.([pth1, pth2], 100; attenuation_stopband=100)

pth1_A = aweighting(pth1)

pths_norm = remove_dc_offset.([pth1, pth2])
pths_norm = normalize(pths_norm; offset_peak_dB=-1.0)

plot_history(pths_norm; fname="out/normalized.png", label=["1", "2"], alpha=1, lw=0.25)

# ==============================================================================
# Integral Metrics
# ==============================================================================

L_p = OASPL(pth1)
L_W = pressure2power(L_p; r=1, Q=1)

