/* eslint-disable */
export function scoreRep(metrics: any, rules: any) {
  // rules is expected to be an object with threshold keys, e.g.
  // { depth_low: { max_knee_angle: 95 }, valgus: { max_valgus_deg: 5 }, tempo: { min_eccentric_s: 1.5 } }
  const errors: any = {};
  let penalty = 0;
  if (!rules) return { score: 1.0, errors };

  if (rules.depth_low && typeof metrics.knee_angle_min === 'number') {
    if (metrics.knee_angle_min > (rules.depth_low.max_knee_angle ?? 95)) {
      errors.depth_low = (errors.depth_low || 0) + 1; penalty += 0.1;
    }
  }

  if (rules.valgus && typeof metrics.knee_valgus_deg === 'number') {
    if (metrics.knee_valgus_deg > (rules.valgus.max_valgus_deg ?? 5)) {
      errors.valgus = (errors.valgus || 0) + 1; penalty += 0.1;
    }
  }

  if (rules.tempo && typeof metrics.tempo_s === 'number') {
    if (metrics.tempo_s < (rules.tempo.min_eccentric_s ?? 1.5)) {
      errors.tempo = (errors.tempo || 0) + 1; penalty += 0.05;
    }
  }

  const score = Math.max(0, 1 - penalty);
  return { score, errors };
}
