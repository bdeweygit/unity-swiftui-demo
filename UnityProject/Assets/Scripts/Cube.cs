using UnityEngine;

public class Cube : MonoBehaviour
{
    void Update()
    {
        NativeState state = NativeStateManager.State;

        // Compute next state
        Vector3 nextLocalScale = new Vector3(state.scale, state.scale, state.scale);
        Texture2D nextMainTexture = null;
        if (state.texture != System.IntPtr.Zero) {
            /* In practice it looks like our values for width and height are ignored.
               It probably determines correct values from the native MTLTexture's own properties.
               Documentation still insists that we pass the correct width and height values, so we will.*/
            nextMainTexture = Texture2D.CreateExternalTexture(state.textureWidth, state.textureHeight, TextureFormat.BGRA32, false, false, state.texture);
        }

        // Update state
        transform.localScale = nextLocalScale;
        GetComponent<Renderer>().material.mainTexture = nextMainTexture;
    }
}