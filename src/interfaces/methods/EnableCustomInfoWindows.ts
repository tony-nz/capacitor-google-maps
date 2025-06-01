export interface EnableCustomInfoWindowsOptions {
  /**
   * @since 2.0.0
   */
  mapId: string;
  /**
   * Whether to enable custom info windows
   * @default true
   * @since 2.0.0
   */
  enabled?: boolean;
}

export interface EnableCustomInfoWindowsResult {
  /**
   * Whether custom info windows are enabled
   * @since 2.0.0
   */
  enabled: boolean;
}
