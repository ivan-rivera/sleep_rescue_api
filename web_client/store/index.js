export const state = () => ({
  showScreenBlur: false,
  showSignInModal: false,
  showResetModal: false,
})

export const mutations = {
  toggleSignInModal(state) {
    state.showSignInModal = !state.showSignInModal
    state.showScreenBlur = !state.showScreenBlur
  },
  toggleResetModal(state) {
    state.showResetModal = !state.showResetModal
    state.showScreenBlur = !state.showScreenBlur
  },
}
