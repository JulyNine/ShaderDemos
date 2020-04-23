using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.VFX;
using UnityEngine.Experimental.VFX.Utility;
using UnityEngine.Playables;
public class FireStoneVFX : MonoBehaviour
{
    public GameObject stone;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if(stone != null)
            this.transform.position = stone.transform.position;
    }


}
