using Revise
using AcousticAnalysis
using WAV
using Statistics
using PyFormattedStrings

# using AcousticMetrics: P_REF
# using AcousticMetrics: r2rfftfreq, rfft, rfft!, irfft, irfft!, RFFTCache, dft_r2hc, dft_hc2r
# using AcousticMetrics: PressureTimeHistory
# using AcousticMetrics: PressureSpectrumAmplitude, PressureSpectrumPhase, 
#     MSPSpectrumAmplitude, MSPSpectrumPhase, 
#     PowerSpectralDensityAmplitude, PowerSpectralDensityPhase
# using AcousticMetrics: starttime, timestep, time, pressure, frequency, halfcomplex, OASPL, samplerate
# using AcousticMetrics: band_start, band_end
# using AcousticMetrics: ExactOctaveCenterBands, ExactOctaveLowerBands, ExactOctaveUpperBands
# using AcousticMetrics: ExactThirdOctaveCenterBands, ExactThirdOctaveLowerBands, ExactThirdOctaveUpperBands
# using AcousticMetrics: ExactProportionalBands, lower_bands, center_bands, upper_bands
# using AcousticMetrics: ProportionalBandSpectrum, ExactThirdOctaveSpectrum
# using AcousticMetrics: ApproximateOctaveBands, ApproximateOctaveCenterBands, ApproximateOctaveLowerBands, ApproximateOctaveUpperBands
# using AcousticMetrics: ApproximateThirdOctaveBands, ApproximateThirdOctaveCenterBands, ApproximateThirdOctaveLowerBands, ApproximateThirdOctaveUpperBands
# using AcousticMetrics: W_A


using PyPlot, PyCall
pplt = pyimport("proplot")
plt = pyimport("matplotlib.pyplot")
pplt.close("all")

# read wav file
s1, fs1 = wavread("data/01.wav")
s2, fs2 = wavread("data/00.wav")

s1 = s1[400:end,1]
s2 = s2[400:end,1]
fs1 = Float64(fs1)
fs2 = Float64(fs2)
p1 = s1 .- mean(s1)
p2 = s2 .- mean(s2)

pth1 = PressureTimeHistory(p1, 1/fs1)
# pth2 = PressureTimeHistory(p2, 1/fs2)

bpf1=66.6667
bpf2=100

# plot_spectrogram(pth1; ylim=(0, 1000), fname="plots/spectrogram.png", t_window=0.5)
# plot_history(pth2; fname="plots/time_history.png", label="2")
# plot_narrowband_spectrum(pth1; bpf=bpf1, fname="plots/spectrum_psd.png", type=:psd, aweighting=true)
# plot_narrowband_spectrum(p2, fs2; bpf=bpf2, fname="plots/spectrum_psa.png")
# plot_narrowband_spectrum([pth1, pth2]; bpf=[bpf1,bpf2], fname="plots/spectrum_narrowband.png", label=["00", "01"])
# plot_history([pth1, pth2]; label=["1", "2"])
# plot_proportional_spectrum(pth2; aweighting=false)
# plot_proportional_spectrum([pth1, pth2]; aweighting=true, fname="plots/spectrum_proportional_A.png", label=["1", "2"])

OASPL(pth1)


# pth1_A = aweighting(pth1)

# plot_narrowband_spectrum(pth1)
# plot_proportional_spectrum(pth1, fname="plots/spectrum_proportional.png")
# plot_narrowband_spectrum([pth1, pth1_A], label=[f"{OASPL(pth1):0.2f} dB", f"{OASPL(pth1_A):0.2f} dB(A)"], fname="plots/spectrum_narrow.png")


MSST = msst(pth1, 4; length_window=512)

noise_floor = -50
T_msst_plot = 20.0 * log10.(abs.(MSST) / P_REF)
T_msst_plot_min = minimum(T_msst_plot[.!isinf.(T_msst_plot)])
T_msst_plot = ifelse.(isinf.(T_msst_plot), noise_floor, T_msst_plot)

t_msst = AcousticAnalysis.time(pth1)
f_msst = Vector(LinRange(0, fs1/2, size(MSST, 1)))

fig, ax = plt.subplots(figsize=(7, 3))
# if t_window > 0.2

#     mesh = ax[1].pcolorfast(
#         t,
#         f_msst,
#         T_msst_plot,
#         # shading="gouraud",
#         vmin=maximum([T_msst_plot_min, noise_floor, maximum(T_msst_plot) - 45.0]),
#         vmax=maximum(T_msst_plot),
#         rasterized=True,
#     )  # type: ignore
# else

mesh = ax.pcolorfast(
    t_msst,
    f_msst,
    T_msst_plot,
    # shading="gouraud",
    vmin=maximum([T_msst_plot_min, noise_floor, maximum(T_msst_plot) - 45.0]),
    vmax=maximum(T_msst_plot),
    rasterized=true,
)  # type: ignore
# end

cbar = fig.colorbar(mesh, ax=ax, label="dB")
ax.set(
    ylim=(f_msst[1], f_msst[end]),
    title="MSST",
    xlabel="t [s]",
    ylabel="f [Hz]",
)