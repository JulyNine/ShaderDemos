using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.VFX;

public class StoneController : MonoBehaviour
{
    private Rigidbody rd;
    Vector3 direction = new Vector3(-5, -1f, -5);
    public VisualEffect effect;
    // Start is called before the first frame update
    void Start()
    {
        rd = gameObject.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        rd.AddForce(direction);//对物体施加力
    }


    void OnCollisionEnter(Collision collision)
    {
        effect.SendEvent("OnCollider");
        Destroy(this.gameObject);
    }

}
